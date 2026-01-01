resource "aws_s3_bucket" "glue_script" {
  bucket        = "${var.environment}-${var.project}-glue-script"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.glue_script.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}