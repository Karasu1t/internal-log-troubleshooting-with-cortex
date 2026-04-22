variable "project" {
  type        = string
  description = "Short project id (e.g. karasuit)."
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev)."
}

variable "staging_bucket_arn" {
  type        = string
  description = "ARN of the Glue Parquet staging bucket."
}

variable "parquet_prefix" {
  type        = string
  description = "S3 key prefix for Parquet objects (no leading slash; trailing slash optional)."
  default     = "logs/parquet"
}

variable "snowflake_storage_user_arn" {
  type        = string
  description = "STORAGE_AWS_IAM_USER_ARN from Snowflake DESCRIBE STORAGE INTEGRATION."
}

variable "snowflake_external_id" {
  type        = string
  description = "STORAGE_AWS_EXTERNAL_ID from Snowflake DESCRIBE STORAGE INTEGRATION."
}

variable "snowflake_glue_catalog_user_arn" {
  type        = string
  default     = ""
  description = "GLUE_AWS_IAM_USER_ARN from DESC CATALOG INTEGRATION (different from STORAGE; required for Iceberg/Glue API)."
}

variable "snowflake_glue_catalog_external_id" {
  type        = string
  default     = ""
  sensitive   = true
  description = "GLUE_AWS_EXTERNAL_ID from DESC CATALOG INTEGRATION."
}

variable "external_volume_trust" {
  type = object({
    snowflake_external_id              = string
    snowflake_external_volume_user_arn = string
  })
  default = {
    snowflake_external_id              = ""
    snowflake_external_volume_user_arn = ""
  }
  sensitive = true
  description = <<-EOT
    EXTERNAL VOLUME S3 location from DESCRIBE EXTERNAL VOLUME (third sts:ExternalId vs STORAGE INTEGRATION).
    Use empty strings to omit the SnowflakeExternalVolumeS3 trust statement. If snowflake_external_volume_user_arn is empty, IAM logic falls back to snowflake_storage_user_arn.
  EOT
}

variable "aws_region" {
  type        = string
  description = "AWS region (for Glue catalog IAM ARNs)."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID (for Glue catalog IAM ARNs)."
}

variable "glue_database_name" {
  type        = string
  description = "Glue Data Catalog database name that holds the Iceberg table (read-only for Snowflake)."
}
