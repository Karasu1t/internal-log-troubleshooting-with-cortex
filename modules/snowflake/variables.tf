variable "project" {
  type        = string
  description = "Short project id (e.g. karasuit)."
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev)."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the staging Parquet bucket (used in STORAGE_AWS_ROLE_ARN; must match the account where the reader IAM role is created)."
}

variable "aws_region" {
  type        = string
  description = "AWS region of the Glue Data Catalog (for Snowflake catalog integration)."
  default     = "ap-northeast-1"
}

variable "warehouse_comment" {
  type        = string
  description = "Comment on the warehouse resource."
  default     = "Terraform: portfolio warehouse"
}

variable "database_comment" {
  type        = string
  description = "Comment on the database resource."
  default     = "Terraform: portfolio database"
}

variable "schema_comment" {
  type        = string
  description = "Comment on the schema resource."
  default     = "Terraform: staging schema for Iceberg / Cortex objects"
}

# Glue must expose lambda_logs before this DDL can succeed. Keep false for the first Snowflake apply (storage
# integration outputs for AWS), then set true after env/dev/aws + Glue job register the table.
variable "create_iceberg_table_ddl" {
  type        = bool
  default     = false
  description = "If true, run snowflake_execute CREATE ICEBERG TABLE (requires Glue Data Catalog table lambda_logs)."
}
