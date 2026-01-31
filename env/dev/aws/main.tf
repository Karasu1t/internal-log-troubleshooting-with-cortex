##############################################
# S3
##############################################
module "s3_lambda_raw_logs_bucket" {
  source      = "../../../modules/aws/s3_lambda_raw_logs_bucket"
  project     = local.project
  environment = local.environment
}

module "s3_glue_script" {
  source      = "../../../modules/aws/s3_glue_script"
  project     = local.project
  environment = local.environment
}

module "s3_staging_parquet_bucket" {
  source      = "../../../modules/aws/s3_staging_parquet_bucket"
  project     = local.project
  environment = local.environment
}

##############################################
# CloudWatch Logs
##############################################
module "cloudwatch_logs" {
  source      = "../../../modules/aws/cloudwatch_logs"
  project     = local.project
  environment = local.environment
}

##############################################
# Lambda
##############################################
module "lambda_demo" {
  source      = "../../../modules/aws/lamda_demo"
  project     = local.project
  environment = local.environment
}

##############################################
# API Gateway
##############################################
module "apigateway" {
  source               = "../../../modules/aws/apigateway"
  project              = local.project
  environment          = local.environment
  lambda_function_arn  = module.lambda_demo.lambda_function_arn
  lambda_function_name = module.lambda_demo.lambda_function_name
}

##############################################
# Kinesis Firehose
##############################################
module "kinesis_firehose" {
  source                  = "../../../modules/aws/kinesis_firehose"
  project                 = local.project
  environment             = local.environment
  s3_bucket_arn           = module.s3_lambda_raw_logs_bucket.bucket_arn
  log_group_name          = module.cloudwatch_logs.log_group_name
  firehose_log_group_name = module.cloudwatch_logs.firehose_log_group_name

  depends_on = [module.cloudwatch_logs]
}

##############################################
# Glue Job (JSON -> Parquet)
##############################################
module "glue_json_to_parquet" {
  source             = "../../../modules/aws/glue_json_to_parquet"
  project            = local.project
  environment        = local.environment
  raw_bucket_arn     = module.s3_lambda_raw_logs_bucket.bucket_arn
  raw_bucket_id      = module.s3_lambda_raw_logs_bucket.bucket_id
  staging_bucket_arn = module.s3_staging_parquet_bucket.bucket_arn
  staging_bucket_id  = module.s3_staging_parquet_bucket.bucket_id
  script_bucket_id   = module.s3_glue_script.bucket_id
}

##############################################
# EventBridge Scheduler (Glue Job)
##############################################
module "eventbridge_glue_scheduler" {
  source              = "../../../modules/aws/eventbridge_glue_scheduler"
  project             = local.project
  environment         = local.environment
  glue_job_name       = module.glue_json_to_parquet.job_name
  glue_job_arn        = module.glue_json_to_parquet.job_arn
  schedule_expression = "cron(0 22 * * ? *)"
  schedule_timezone   = "Asia/Tokyo"
  target_date         = "AUTO"
}

##############################################
# Outputs
##############################################
output "api_gateway_url" {
  value = module.apigateway.api_url
}
