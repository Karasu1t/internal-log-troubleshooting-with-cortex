variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "glue_job_name" {
  type = string
}

variable "glue_job_arn" {
  type = string
}

variable "schedule_expression" {
  type    = string
  default = "cron(0 22 * * ? *)"
}

variable "schedule_timezone" {
  type    = string
  default = "Asia/Tokyo"
}

variable "target_date" {
  type    = string
  default = "AUTO"
}
