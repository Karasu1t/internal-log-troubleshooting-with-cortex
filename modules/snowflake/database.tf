resource "snowflake_database" "log_analytics" {
  name    = local.database_name
  comment = var.database_comment
}
