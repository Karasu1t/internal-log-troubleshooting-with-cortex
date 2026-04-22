output "role_arn" {
  description = "IAM role assumed by Snowflake for staging Parquet reads."
  value       = aws_iam_role.snowflake_staging_s3_reader.arn
}

output "role_name" {
  value = aws_iam_role.snowflake_staging_s3_reader.name
}

output "glue_catalog_trust_configured" {
  description = "True when GLUE_AWS_IAM_USER_ARN + GLUE_AWS_EXTERNAL_ID were passed (second trust statement on the role). Must be true before Snowflake CREATE ICEBERG TABLE."
  value       = local.glue_catalog_trust
}

output "glue_trust_principal_as_deployed" {
  description = "Principal.AWS from SnowflakeGlueCatalogIntegration (parsed from IAM role trust). Matches Snowflake GLUE_AWS_IAM_USER_ARN when trust is configured; null if not."
  value       = try(local.glue_from_aws_statement.Principal.AWS, null)
}

output "glue_trust_external_id_as_deployed" {
  description = "sts:ExternalId from the same statement. Matches GLUE_AWS_EXTERNAL_ID when configured."
  value       = try(local.glue_from_aws_statement.Condition.StringEquals["sts:ExternalId"], null)
  sensitive   = true
}
