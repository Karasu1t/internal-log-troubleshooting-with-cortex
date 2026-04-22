output "bucket_arn" {
  description = "The ARN of the staging parquet S3 bucket"
  value       = aws_s3_bucket.staging_parquet_bucket.arn
}

output "bucket_id" {
  description = "The ID of the staging parquet S3 bucket"
  value       = aws_s3_bucket.staging_parquet_bucket.id
}
