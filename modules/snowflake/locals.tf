locals {
  database_name                         = upper("${var.environment}_${var.project}_LOG_ANALYTICS")
  schema_name                           = "STAGING"
  warehouse_name                        = upper("${var.environment}_${var.project}_WH_XS")
  staging_parquet_bucket_id             = "${var.environment}-${var.project}-staging-parquet-bucket"
  snowflake_staging_s3_reader_role_name = "${var.environment}-${var.project}-snowflake-staging-s3-reader"
  # Primary prefix for Iceberg files / EXTERNAL VOLUME (Glue writes here).
  staging_parquet_s3_prefix = "logs/iceberg"
  # STORAGE INTEGRATION allowed locations (Iceberg files under this prefix; same bucket as Glue warehouse).
  staging_s3_allowed_prefixes = [
    "logs/iceberg",
  ]
  storage_integration_name = upper("${var.environment}_${var.project}_S3_STAGING_PARQUET_INT")
  # Must match Glue: aws_glue_catalog_database + Iceberg table name in json_to_iceberg.py
  iceberg_glue_database_name = "${var.environment}_${var.project}_log_warehouse"
  iceberg_glue_table_name    = "lambda_logs"

  external_volume_name          = upper("${var.environment}_${var.project}_ICEBERG_VOL")
  glue_catalog_integration_name = upper("${var.environment}_${var.project}_GLUE_CATALOG")
  iceberg_table_name = upper("${var.environment}_${var.project}_LAMBDA_LOGS_ICEBERG")

  # Must match snowflake_external_volume.iceberg_logs storage_location.storage_location_name (Iceberg S3 reads).
  iceberg_external_volume_s3_location_name = "S3_ICEBERG"

  # Third trust pair for IAM: EXTERNAL VOLUME uses its own STORAGE_AWS_EXTERNAL_ID (see DESCRIBE EXTERNAL VOLUME).
  iceberg_external_volume_s3_external_ids = [
    for loc in try(snowflake_external_volume.iceberg_logs.describe_output[0].storage_locations, []) :
    loc.s3_storage_location[0].storage_aws_external_id
    if try(loc.name, "") == local.iceberg_external_volume_s3_location_name && length(try(loc.s3_storage_location, [])) > 0
  ]
  iceberg_external_volume_s3_iam_user_arns = [
    for loc in try(snowflake_external_volume.iceberg_logs.describe_output[0].storage_locations, []) :
    loc.s3_storage_location[0].storage_aws_iam_user_arn
    if try(loc.name, "") == local.iceberg_external_volume_s3_location_name && length(try(loc.s3_storage_location, [])) > 0
  ]
}
