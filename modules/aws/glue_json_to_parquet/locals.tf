locals {
  glue_iceberg_db_name = "${var.environment}_${var.project}_log_warehouse"
  # Glue default_arguments cannot repeat the --conf key; chain multiple Spark configs in one value (AWS Glue pattern).
  # Registers Iceberg SparkCatalog + GlueCatalog impl so glue_catalog exists before setCurrentCatalog (see json_to_iceberg.py).
  iceberg_glue_catalog_conf = join(" --conf ", [
    "spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog",
    "spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog",
    "spark.sql.catalog.glue_catalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO",
    # No trailing slash: avoids Iceberg paths like .../iceberg//<table>/metadata (Snowflake 091325 missing file).
    "spark.sql.catalog.glue_catalog.warehouse=s3://${var.staging_bucket_id}/logs/iceberg",
    "spark.sql.catalog.glue_catalog.glue.id=${data.aws_caller_identity.current.account_id}",
    "spark.sql.catalog.glue_catalog.glue.region=${var.aws_region}",
  ])
}
