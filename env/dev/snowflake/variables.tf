variable "snowflake_organization_name" {
  type        = string
  description = "Snowflake organization name (from account URL / admin UI)."
}

variable "snowflake_account_name" {
  type        = string
  description = "Snowflake account name within the organization."
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake user for Terraform (create TF_USER manually; see terraform.tfvars.example)."
  default     = "TF_USER"
}

variable "snowflake_password" {
  type        = string
  description = "Password for snowflake_user."
  sensitive   = true
}

variable "snowflake_role" {
  type        = string
  description = "Active role for the provider session. TF_USER is usually granted SYSADMIN for dev bootstrap; use ACCOUNTADMIN only if your account has no other option."
  default     = "SYSADMIN"
}

# Session warehouse for the Snowflake provider (plan/apply and snowflake_execute). Must already exist in the
# account when state is empty (e.g. after terraform destroy). The Terraform-managed warehouse in modules/snowflake
# is created by this stack; do not use that warehouse's name here until it exists.
variable "snowflake_provider_warehouse" {
  type        = string
  description = "Existing warehouse the provider user/role can use (often COMPUTE_WH). Override via TF_VAR if your account has no COMPUTE_WH."
  default     = "COMPUTE_WH"
}

variable "create_iceberg_table_ddl" {
  type        = bool
  default     = false
  description = "Set true only after env/dev/aws apply and Glue job registered lambda_logs in Glue Data Catalog (second-phase Snowflake apply)."
}
