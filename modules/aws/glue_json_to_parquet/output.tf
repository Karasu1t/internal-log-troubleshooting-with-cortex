output "job_name" {
  description = "The name of the Glue job"
  value       = aws_glue_job.json_to_parquet.name
}

output "job_arn" {
  description = "The ARN of the Glue job"
  value       = aws_glue_job.json_to_parquet.arn
}

output "role_arn" {
  description = "The ARN of the Glue job role"
  value       = aws_iam_role.glue_job_role.arn
}

output "glue_database_name" {
  description = "Glue Data Catalog database name for Iceberg tables."
  value       = aws_glue_catalog_database.iceberg.name
}
