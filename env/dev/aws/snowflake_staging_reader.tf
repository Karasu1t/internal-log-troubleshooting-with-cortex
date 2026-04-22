data "terraform_remote_state" "snowflake" {
  backend = "s3"
  config = {
    bucket       = "karasuit"
    key          = "snowflake.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}

locals {
  # Remote state can have empty outputs (Snowflake not applied yet). Prefer RS, then TF_VAR fallbacks.
  snowflake_rs_user_arn = try(data.terraform_remote_state.snowflake.outputs.storage_integration_staging_parquet_user_arn, "")
  snowflake_rs_ext_id   = try(data.terraform_remote_state.snowflake.outputs.storage_integration_staging_parquet_external_id, "")
  snowflake_storage_user_arn = length(trimspace(local.snowflake_rs_user_arn)) > 0 ? trimspace(local.snowflake_rs_user_arn) : trimspace(var.snowflake_storage_integration_user_arn)
  snowflake_external_id      = length(trimspace(local.snowflake_rs_ext_id)) > 0 ? trimspace(local.snowflake_rs_ext_id) : trimspace(var.snowflake_storage_integration_external_id)

  snowflake_rs_ev_ext_id  = try(data.terraform_remote_state.snowflake.outputs.external_volume_s3_storage_aws_external_id, "")
  snowflake_rs_ev_user_arn = try(data.terraform_remote_state.snowflake.outputs.external_volume_s3_storage_aws_iam_user_arn, "")
  snowflake_external_volume_external_id = length(trimspace(local.snowflake_rs_ev_ext_id)) > 0 ? trimspace(local.snowflake_rs_ev_ext_id) : trimspace(var.snowflake_external_volume_external_id)
  snowflake_external_volume_user_arn = length(trimspace(local.snowflake_rs_ev_user_arn)) > 0 ? trimspace(local.snowflake_rs_ev_user_arn) : trimspace(var.snowflake_external_volume_user_arn)
}

resource "terraform_data" "snowflake_trust_configured" {
  lifecycle {
    precondition {
      condition = (
        length(local.snowflake_storage_user_arn) > 0 &&
        length(local.snowflake_external_id) > 0
      )
      error_message = <<-EOT
        Snowflake remote state has no storage integration outputs. Apply env/dev/snowflake first (so snowflake.tfstate exports them), or set:
          TF_VAR_snowflake_storage_integration_user_arn
          TF_VAR_snowflake_storage_integration_external_id
        (from Snowflake: DESCRIBE STORAGE INTEGRATION <name>; STORAGE_AWS_IAM_USER_ARN / STORAGE_AWS_EXTERNAL_ID).
      EOT
    }
  }
}

module "snowflake_staging_s3_reader" {
  source = "../../../modules/aws/snowflake_staging_s3_reader"

  project        = local.project
  environment    = local.environment
  aws_region     = local.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id

  staging_bucket_arn = module.s3_staging_parquet_bucket.bucket_arn
  parquet_prefix     = "logs/iceberg"

  glue_database_name = module.glue_json_to_parquet.glue_database_name

  snowflake_storage_user_arn = local.snowflake_storage_user_arn
  snowflake_external_id      = local.snowflake_external_id

  snowflake_glue_catalog_user_arn    = trimspace(var.snowflake_glue_catalog_user_arn)
  snowflake_glue_catalog_external_id = trimspace(var.snowflake_glue_catalog_external_id)

  external_volume_trust = {
    snowflake_external_id              = local.snowflake_external_volume_external_id
    snowflake_external_volume_user_arn = local.snowflake_external_volume_user_arn
  }

  depends_on = [
    module.glue_json_to_parquet,
    terraform_data.snowflake_trust_configured,
  ]
}
