resource "aws_cloudwatch_log_group" "lamda_log_group" {
  name              = "/aws/lambda/lambda_demo_function"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "firehose_logs" {
  name              = "/aws/kinesisfirehose/logs-to-s3"
  retention_in_days = 7
}
