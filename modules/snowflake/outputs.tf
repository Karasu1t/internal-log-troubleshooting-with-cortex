output "warehouse_name" {
  value = snowflake_warehouse.compute.name
}

output "database_name" {
  value = snowflake_database.log_analytics.name
}

output "schema_name" {
  value = snowflake_schema.staging.name
}

output "fully_qualified_staging" {
  value = "${snowflake_database.log_analytics.name}.${snowflake_schema.staging.name}"
}

output "storage_integration_staging_parquet_user_arn" {
  description = "Snowflake service user for STORAGE INTEGRATION trust policy Principal."
  value       = snowflake_storage_integration.staging_parquet.storage_aws_iam_user_arn
}

output "storage_integration_staging_parquet_external_id" {
  description = "External ID for STORAGE INTEGRATION trust policy Condition."
  value       = snowflake_storage_integration.staging_parquet.describe_output[0].storage_aws_external_id[0].value
}

output "fully_qualified_iceberg_table_lambda_logs" {
  description = "Iceberg table in Snowflake when create_iceberg_table_ddl is true; otherwise null until DDL runs."
  value       = var.create_iceberg_table_ddl ? "${snowflake_database.log_analytics.name}.${snowflake_schema.staging.name}.${local.iceberg_table_name}" : null
}

output "iceberg_external_volume_name" {
  value = snowflake_external_volume.iceberg_logs.name
}

output "glue_catalog_integration_name" {
  value = snowflake_catalog_integration_aws_glue.glue.name
}

output "external_volume_s3_storage_aws_external_id" {
  description = "DESCRIBE EXTERNAL VOLUME: STORAGE_AWS_EXTERNAL_ID for the Iceberg S3 location (metadata/data reads). Usually not equal to STORAGE INTEGRATION external ID."
  value       = length(local.iceberg_external_volume_s3_external_ids) > 0 ? local.iceberg_external_volume_s3_external_ids[0] : ""
}

output "external_volume_s3_storage_aws_iam_user_arn" {
  description = "DESCRIBE EXTERNAL VOLUME: STORAGE_AWS_IAM_USER_ARN for the Iceberg S3 location (trust policy Principal)."
  value       = length(local.iceberg_external_volume_s3_iam_user_arns) > 0 ? local.iceberg_external_volume_s3_iam_user_arns[0] : ""
}
