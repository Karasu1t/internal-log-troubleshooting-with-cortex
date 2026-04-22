resource "snowflake_warehouse" "compute" {
  name           = local.warehouse_name
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true
  comment        = var.warehouse_comment
}
