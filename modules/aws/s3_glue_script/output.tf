output "bucket_arn" {
	description = "The ARN of the Glue script S3 bucket"
	value       = aws_s3_bucket.glue_script.arn
}

output "bucket_id" {
	description = "The ID of the Glue script S3 bucket"
	value       = aws_s3_bucket.glue_script.id
}
