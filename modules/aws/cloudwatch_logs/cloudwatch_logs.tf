resource "aws_cloudwatch_log_group" "lamda_log_group" {
  name = "${var.environment}-${var.project}-lambda-log-group"
  retention_in_days = 7
}