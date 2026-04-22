resource "snowflake_storage_integration" "staging_parquet" {
  name    = local.storage_integration_name
  type    = "EXTERNAL_STAGE"
  enabled = true
  comment = "Portfolio: S3 prefix for Iceberg data files (EXTERNAL VOLUME reads via this integration’s IAM role)."

  storage_provider = "S3"
  storage_allowed_locations = [
    for p in local.staging_s3_allowed_prefixes : "s3://${local.staging_parquet_bucket_id}/${trimsuffix(p, "/")}/"
  ]
  storage_aws_role_arn = "arn:aws:iam::${var.aws_account_id}:role/${local.snowflake_staging_s3_reader_role_name}"
}
