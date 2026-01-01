output "log_group_name" {
  value       = aws_cloudwatch_log_group.lamda_log_group.name
}

output "log_group_arn" {
  value       = aws_cloudwatch_log_group.lamda_log_group.arn
}
