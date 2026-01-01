resource "aws_s3_bucket" "lambda_raw_logs_bucket" {
  bucket        = "${var.environment}-${var.project}-lambda-raw-logs-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.lambda_raw_logs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}