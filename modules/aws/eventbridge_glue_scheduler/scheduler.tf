resource "aws_scheduler_schedule" "glue_job" {
  name = "${var.environment}-${var.project}-glue-json-to-parquet-schedule"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:glue:startJobRun"
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      JobName = var.glue_job_name
      Arguments = {
        "--target_date" = var.target_date
      }
    })
  }
}
