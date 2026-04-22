resource "snowflake_schema" "staging" {
  database = snowflake_database.log_analytics.name
  name     = local.schema_name
  comment  = var.schema_comment
}
