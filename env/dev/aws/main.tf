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
# Outputs
##############################################
output "api_gateway_url" {
  value = module.apigateway.api_url
}
