##############################################
# Snowflake — bootstrap (warehouse / database / schema)
##############################################
module "snowflake_bootstrap" {
  source = "../../../modules/snowflake"

  project        = local.project
  environment    = local.environment
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = local.aws_region

  warehouse_comment = "Portfolio: internal-log-troubleshooting-with-cortex (dev)"
  database_comment  = "Portfolio: Lambda log pipeline → analytics / Cortex (dev)"
  schema_comment    = "Staging area for Iceberg tables (Glue Catalog) and Cortex (dev)"

  # false: first apply outputs STORAGE INTEGRATION for AWS. true: after Glue has lambda_logs, run Iceberg DDL.
  create_iceberg_table_ddl = var.create_iceberg_table_ddl
}
