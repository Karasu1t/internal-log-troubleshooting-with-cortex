output "warehouse" {
  value       = module.snowflake_bootstrap.warehouse_name
  description = "Warehouse for this environment."
}

output "database" {
  value       = module.snowflake_bootstrap.database_name
  description = "Database for log analytics."
}

output "schema" {
  value       = module.snowflake_bootstrap.schema_name
  description = "Default staging schema."
}

output "fully_qualified_staging" {
  value       = module.snowflake_bootstrap.fully_qualified_staging
  description = "DATABASE.SCHEMA for staging objects."
}

output "storage_integration_staging_parquet_user_arn" {
  value       = module.snowflake_bootstrap.storage_integration_staging_parquet_user_arn
  description = "STORAGE_AWS_IAM_USER_ARN from DESCRIBE STORAGE INTEGRATION (for IAM role trust)."
}

output "storage_integration_staging_parquet_external_id" {
  value       = module.snowflake_bootstrap.storage_integration_staging_parquet_external_id
  description = "STORAGE_AWS_EXTERNAL_ID from DESCRIBE STORAGE INTEGRATION (for IAM role trust)."
}

output "fully_qualified_iceberg_table_lambda_logs" {
  value       = module.snowflake_bootstrap.fully_qualified_iceberg_table_lambda_logs
  description = "Iceberg table (Glue Catalog) for Lambda logs."
}

output "iceberg_external_volume_name" {
  value       = module.snowflake_bootstrap.iceberg_external_volume_name
  description = "EXTERNAL_VOLUME used by the Iceberg table."
}

output "glue_catalog_integration_name" {
  value       = module.snowflake_bootstrap.glue_catalog_integration_name
  description = "AWS Glue catalog integration for Iceberg metadata."
}

output "external_volume_s3_storage_aws_external_id" {
  value       = module.snowflake_bootstrap.external_volume_s3_storage_aws_external_id
  description = "EXTERNAL VOLUME S3 STORAGE_AWS_EXTERNAL_ID for IAM trust (Iceberg files on S3)."
}

output "external_volume_s3_storage_aws_iam_user_arn" {
  value       = module.snowflake_bootstrap.external_volume_s3_storage_aws_iam_user_arn
  description = "EXTERNAL VOLUME S3 STORAGE_AWS_IAM_USER_ARN for IAM trust Principal."
}
