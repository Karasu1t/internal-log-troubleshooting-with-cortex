resource "aws_cloudwatch_log_group" "lamda_log_group" {
  name              = "/aws/lambda/lambda_demo_function"
  retention_in_days = 7
}