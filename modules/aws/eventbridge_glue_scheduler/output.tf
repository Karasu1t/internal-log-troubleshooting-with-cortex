output "schedule_arn" {
  description = "The ARN of the EventBridge Scheduler schedule"
  value       = aws_scheduler_schedule.glue_job.arn
}
