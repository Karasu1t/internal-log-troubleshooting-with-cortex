resource "aws_s3_bucket" "etl_bucket" {
  bucket        = "${var.environment}-${var.project}-etl-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.etl_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}