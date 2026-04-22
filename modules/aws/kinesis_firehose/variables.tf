variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "firehose_log_group_name" {
  type        = string
  description = "CloudWatch Log Group name used by Firehose for delivery logs"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch Log Group name to subscribe"
}

variable "s3_prefix_time_zone" {
  type        = string
  description = "IANA time zone for S3 object prefix timestamps (e.g. Asia/Tokyo). Must match Glue --target_date AUTO (JST)."
  default     = "Asia/Tokyo"
}
