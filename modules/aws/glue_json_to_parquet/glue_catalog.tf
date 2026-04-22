resource "aws_glue_catalog_database" "iceberg" {
  name         = local.glue_iceberg_db_name
  description  = "Glue Data Catalog database for Iceberg tables (Lambda logs pipeline)."
  location_uri = "s3://${var.staging_bucket_id}/logs/iceberg"
}
