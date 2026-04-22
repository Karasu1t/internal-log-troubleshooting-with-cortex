locals {
  role_name = "${var.environment}-${var.project}-snowflake-staging-s3-reader"
  # Normalize prefix: no leading or trailing slashes (for s3:prefix / object ARNs)
  prefix_trimmed = trimsuffix(trimprefix(var.parquet_prefix, "/"), "/")

  # Read back Glue trust from the deployed IAM assume_role_policy (same info as DESC CATALOG INTEGRATION, after apply).
  trust_decoded = jsondecode(aws_iam_role.snowflake_staging_s3_reader.assume_role_policy)
  glue_trust_statements = [
    for s in try(tolist(local.trust_decoded.Statement), []) : s
    if try(s.Sid, "") == "SnowflakeGlueCatalogIntegration"
  ]
  glue_from_aws_statement = length(local.glue_trust_statements) > 0 ? local.glue_trust_statements[0] : null
}
