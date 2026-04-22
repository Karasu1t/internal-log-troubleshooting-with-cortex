# Snowflake reads Iceberg tables registered in AWS Glue Data Catalog (Glue job writes via Iceberg + glue_catalog).

resource "snowflake_external_volume" "iceberg_logs" {
  name    = local.external_volume_name
  comment = "S3 base URL for Iceberg files (same prefix as Glue warehouse; read via STORAGE INTEGRATION IAM role)."

  allow_writes = "false"

  storage_location {
    storage_location_name = "S3_ICEBERG"
    storage_provider      = "S3"
    # Match Glue Iceberg warehouse (no trailing slash) so table paths stay .../iceberg/<table>/... not .../iceberg//...
    storage_base_url      = "s3://${local.staging_parquet_bucket_id}/${local.staging_parquet_s3_prefix}"
    storage_aws_role_arn  = "arn:aws:iam::${var.aws_account_id}:role/${local.snowflake_staging_s3_reader_role_name}"
  }

  depends_on = [snowflake_storage_integration.staging_parquet]
}

resource "snowflake_catalog_integration_aws_glue" "glue" {
  name                     = local.glue_catalog_integration_name
  enabled                  = true
  comment                  = "AWS Glue Data Catalog for Iceberg tables written by Glue (namespace + table: e.g. dev_*_log_warehouse.lambda_logs)."
  glue_aws_role_arn        = "arn:aws:iam::${var.aws_account_id}:role/${local.snowflake_staging_s3_reader_role_name}"
  glue_catalog_id          = var.aws_account_id
  glue_region              = var.aws_region
  catalog_namespace        = local.iceberg_glue_database_name
  refresh_interval_seconds = 60

  depends_on = [snowflake_storage_integration.staging_parquet]
}

# snowflake_execute allows exactly one statement per field. Do not add USE WAREHOUSE here — provider docs
# forbid it; set provider "snowflake" { warehouse = ... } instead.
resource "snowflake_execute" "lambda_logs_iceberg_table" {
  count = var.create_iceberg_table_ddl ? 1 : 0

  execute = <<-SQL
CREATE OR REPLACE ICEBERG TABLE ${snowflake_database.log_analytics.name}.${snowflake_schema.staging.name}.${local.iceberg_table_name}
  EXTERNAL_VOLUME = '${snowflake_external_volume.iceberg_logs.name}'
  CATALOG = '${snowflake_catalog_integration_aws_glue.glue.name}'
  CATALOG_NAMESPACE = '${local.iceberg_glue_database_name}'
  CATALOG_TABLE_NAME = '${local.iceberg_glue_table_name}'
;
SQL

  revert = <<-SQL
DROP ICEBERG TABLE IF EXISTS ${snowflake_database.log_analytics.name}.${snowflake_schema.staging.name}.${local.iceberg_table_name};
SQL

  depends_on = [
    snowflake_warehouse.compute,
    snowflake_external_volume.iceberg_logs,
    snowflake_catalog_integration_aws_glue.glue,
  ]
}
