resource "aws_s3_bucket" "staging_parquet_bucket" {
  bucket        = "${var.environment}-${var.project}-staging-parquet-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.staging_parquet_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}