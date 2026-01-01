##############################################
# S3
##############################################
module "s3_lambda_raw_logs_bucket" {
  source      = "../../../modules/aws/s3_lambda_raw_logs_bucket"
  project     = local.project
  environment = local.environment
}

module "s3_lambda_script" {
  source      = "../../../modules/aws/s3_lambda_script"
  project     = local.project
  environment = local.environment
}

module "s3_glue_script" {
  source      = "../../../modules/aws/s3_glue_script"
  project     = local.project
  environment = local.environment
}

module "s3_etl_bucket" {
  source      = "../../../modules/aws/s3_etl_bucket"
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