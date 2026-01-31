import base64
import gzip
import sys
from datetime import datetime, timedelta, timezone
from typing import Optional
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.types import ArrayType, LongType, StringType, StructField, StructType
from pyspark.sql.functions import (
    col,
    dayofmonth,
    explode,
    from_unixtime,
    get_json_object,
    hour,
    length,
    month,
    regexp_extract,
    to_timestamp,
    when,
    year,
)

args = getResolvedOptions(sys.argv, ["JOB_NAME", "input_path", "output_path", "TempDir"])

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

input_path = args["input_path"]
output_path = args["output_path"]
target_date = None
if "--target_date" in sys.argv:
    target_date = getResolvedOptions(sys.argv, ["target_date"]).get("target_date")

raw_schema = StructType(
    [
        StructField("messageType", StringType(), True),
        StructField("owner", StringType(), True),
        StructField("logGroup", StringType(), True),
        StructField("logStream", StringType(), True),
        StructField("subscriptionFilters", ArrayType(StringType()), True),
        StructField(
            "logEvents",
            ArrayType(
                StructType(
                    [
                        StructField("id", StringType(), True),
                        StructField("timestamp", LongType(), True),
                        StructField("message", StringType(), True),
                    ]
                )
            ),
            True,
        ),
    ]
)

def resolve_input_prefix(base_path: str, date_value: Optional[str]) -> str:
    if not date_value or date_value.upper() == "AUTO":
        jst = timezone(timedelta(hours=9))
        date_value = datetime.now(jst).strftime("%Y/%m/%d")
    else:
        date_value = date_value.strip().replace("-", "/")

    return f"{base_path.rstrip('/')}/{date_value}/"


input_prefix = resolve_input_prefix(input_path, target_date)

binary_df = (
    spark.read.format("binaryFile")
    .option("recursiveFileLookup", "true")
    .load(input_prefix)
)


def _decompress_gzip_layers(data: bytes) -> bytes:
    while data[:2] == b"\x1f\x8b":
        data = gzip.decompress(data)
    return data


def decode_payload(payload: bytes) -> Optional[str]:
    data = _decompress_gzip_layers(payload)

    if data[:2] == b"H4" or data.startswith(b"ey"):
        try:
            decoded = base64.b64decode(data, validate=True)
            data = _decompress_gzip_layers(decoded)
        except Exception:
            pass

    data = _decompress_gzip_layers(data)

    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return None


json_rdd = binary_df.select("content").rdd.map(lambda row: decode_payload(row.content)).filter(
    lambda line: line
)

raw_df = spark.read.schema(raw_schema).json(json_rdd)

exploded = raw_df.withColumn("log_event", explode(col("logEvents")))

base_df = (
    exploded.select(
        col("messageType").alias("message_type"),
        col("owner").alias("owner"),
        col("logGroup").alias("log_group"),
        col("logStream").alias("log_stream"),
        col("subscriptionFilters").alias("subscription_filters"),
        col("log_event.id").alias("event_id"),
        col("log_event.timestamp").alias("event_timestamp"),
        col("log_event.message").alias("event_message"),
    )
    .withColumn(
        "event_time",
        to_timestamp(from_unixtime(col("event_timestamp") / 1000)),
    )
)

with_request_id = base_df.withColumn(
    "request_id",
    when(
        length(regexp_extract(col("event_message"), r"RequestId: ([a-f0-9\-]+)", 1))
        > 0,
        regexp_extract(col("event_message"), r"RequestId: ([a-f0-9\-]+)", 1),
    ),
)

with_report_metrics = (
    with_request_id.withColumn(
        "duration_ms",
        when(
            length(regexp_extract(col("event_message"), r"Duration: ([0-9.]+) ms", 1))
            > 0,
            regexp_extract(col("event_message"), r"Duration: ([0-9.]+) ms", 1).cast("double"),
        ),
    )
    .withColumn(
        "billed_duration_ms",
        when(
            length(regexp_extract(col("event_message"), r"Billed Duration: ([0-9.]+) ms", 1))
            > 0,
            regexp_extract(col("event_message"), r"Billed Duration: ([0-9.]+) ms", 1).cast("double"),
        ),
    )
    .withColumn(
        "memory_size_mb",
        when(
            length(regexp_extract(col("event_message"), r"Memory Size: ([0-9]+) MB", 1))
            > 0,
            regexp_extract(col("event_message"), r"Memory Size: ([0-9]+) MB", 1).cast("int"),
        ),
    )
    .withColumn(
        "max_memory_used_mb",
        when(
            length(regexp_extract(col("event_message"), r"Max Memory Used: ([0-9]+) MB", 1))
            > 0,
            regexp_extract(col("event_message"), r"Max Memory Used: ([0-9]+) MB", 1).cast("int"),
        ),
    )
    .withColumn(
        "init_duration_ms",
        when(
            length(regexp_extract(col("event_message"), r"Init Duration: ([0-9.]+) ms", 1))
            > 0,
            regexp_extract(col("event_message"), r"Init Duration: ([0-9.]+) ms", 1).cast("double"),
        ),
    )
)

with_app_json = (
    with_report_metrics.withColumn("app_ts", get_json_object(col("event_message"), "$.ts"))
    .withColumn("source", get_json_object(col("event_message"), "$.source"))
    .withColumn("path", get_json_object(col("event_message"), "$.path"))
    .withColumn("method", get_json_object(col("event_message"), "$.method"))
    .withColumn("body", get_json_object(col("event_message"), "$.body"))
    .withColumn(
        "status",
        get_json_object(col("event_message"), "$.status").cast("int"),
    )
)

final_df = (
    with_app_json.withColumn("year", year(col("event_time")))
    .withColumn("month", month(col("event_time")))
    .withColumn("day", dayofmonth(col("event_time")))
    .withColumn("hour", hour(col("event_time")))
)

(
    final_df.write.mode("append")
    .partitionBy("year", "month", "day", "hour")
    .parquet(output_path)
)

job.commit()
