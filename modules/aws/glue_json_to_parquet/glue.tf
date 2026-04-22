resource "aws_s3_object" "glue_script" {
  bucket       = var.script_bucket_id
  key          = "glue/json_to_iceberg.py"
  source       = "${path.module}/scripts/json_to_iceberg.py"
  etag         = filemd5("${path.module}/scripts/json_to_iceberg.py")
  content_type = "text/x-python"
}

resource "aws_glue_job" "json_to_parquet" {
  name     = "${var.environment}-${var.project}-json-to-iceberg"
  role_arn = aws_iam_role.glue_job_role.arn

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.script_bucket_id}/${aws_s3_object.glue_script.key}"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--datalake-formats"                 = "iceberg"
    # Iceberg glue_catalog: full SparkCatalog + GlueCatalog registration (see locals.tf)
    "--conf" = local.iceberg_glue_catalog_conf
    "--TempDir"                          = "s3://${var.staging_bucket_id}/temp/"
    "--input_path"                       = "s3://${var.raw_bucket_id}/"
    "--iceberg_warehouse"                = "s3://${var.staging_bucket_id}/logs/iceberg"
    "--glue_database"                    = aws_glue_catalog_database.iceberg.name
    "--iceberg_table_name"               = "lambda_logs"
  }

  depends_on = [aws_glue_catalog_database.iceberg]
}
