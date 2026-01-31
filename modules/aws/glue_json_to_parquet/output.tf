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
