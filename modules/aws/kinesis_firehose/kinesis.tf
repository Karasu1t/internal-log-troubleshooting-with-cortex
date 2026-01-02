resource "aws_kinesis_firehose_delivery_stream" "logs_to_s3" {
  name        = "logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = var.s3_bucket_arn
    buffering_size     = 5 # MB
    buffering_interval = 300
    compression_format = "GZIP"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "cw_to_firehose" {
  name            = "logs-to-firehose"
  log_group_name  = "/aws/lambda/lambda_demo"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_to_s3.arn
  role_arn        = aws_iam_role.firehose_role.arn
}
