resource "aws_kinesis_firehose_delivery_stream" "logs_to_s3" {
  name        = "logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = var.s3_bucket_arn
    buffering_size     = 1  # MB
    buffering_interval = 60 # seconds
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = var.firehose_log_group_name
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "cw_to_firehose" {
  name            = "logs-to-firehose"
  log_group_name  = var.log_group_name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_to_s3.arn
  role_arn        = aws_iam_role.cloudwatch_to_firehose_role.arn

  depends_on = [
    aws_iam_role_policy.cloudwatch_to_firehose_policy
  ]
}
