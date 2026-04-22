# ------------------------------------
# Terraform Cofiguration
# ------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.2"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  region = "ap-northeast-1"
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role

  # Must be an existing warehouse (see var.snowflake_provider_warehouse). Do not use the module-managed warehouse
  # name here until that resource exists, or plan/apply fails with 390201. snowflake_execute uses this session warehouse;
  # do not put USE WAREHOUSE in SQL (single-statement only).
  warehouse = var.snowflake_provider_warehouse

  preview_features_enabled = [
    "snowflake_storage_integration_resource",
    "snowflake_external_volume_resource",
    "snowflake_catalog_integration_aws_glue_resource",
  ]
}
