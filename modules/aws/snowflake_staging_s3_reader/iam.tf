locals {
  # Glue catalog integration often reuses the same Snowflake-managed IAM user as STORAGE INTEGRATION but always
  # uses a different sts:ExternalId (DESC CATALOG INTEGRATION GLUE_AWS_EXTERNAL_ID vs STORAGE_AWS_EXTERNAL_ID).
  glue_catalog_trust = (
    length(trimspace(var.snowflake_glue_catalog_user_arn)) > 0 &&
    length(trimspace(var.snowflake_glue_catalog_external_id)) > 0
  )

  storage_user_arn = trimspace(var.snowflake_storage_user_arn)
  glue_user_arn    = trimspace(var.snowflake_glue_catalog_user_arn)
  storage_ext_id   = trimspace(var.snowflake_external_id)
  glue_ext_id      = trimspace(var.snowflake_glue_catalog_external_id)

  external_volume_ext_id = trimspace(var.external_volume_trust.snowflake_external_id)
  external_volume_principal = (
    length(trimspace(var.external_volume_trust.snowflake_external_volume_user_arn)) > 0 ?
    trimspace(var.external_volume_trust.snowflake_external_volume_user_arn) :
    local.storage_user_arn
  )
  external_volume_trust = (
    length(local.external_volume_ext_id) > 0 &&
    length(local.external_volume_principal) > 0
  )

  # Always a separate Statement per trust pair. Iceberg EXTERNAL VOLUME S3 reads use a third ExternalId vs STORAGE
  # INTEGRATION (same IAM user is common); Glue catalog uses a fourth pair.
  assume_role_statements = flatten([
    [
      {
        Sid    = "SnowflakeStorageIntegration"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.storage_user_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.storage_ext_id
          }
        }
      }
    ],
    local.external_volume_trust ? [
      {
        Sid    = "SnowflakeExternalVolumeS3"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.external_volume_principal
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_volume_ext_id
          }
        }
      }
    ] : [],
    local.glue_catalog_trust ? [
      {
        Sid    = "SnowflakeGlueCatalogIntegration"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.glue_user_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.glue_ext_id
          }
        }
      }
    ] : [],
  ])
}

resource "aws_iam_role" "snowflake_staging_s3_reader" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.assume_role_statements
  })
}

resource "aws_iam_role_policy" "snowflake_staging_s3_read" {
  name = "${var.environment}-${var.project}-snowflake-staging-s3-read"
  role = aws_iam_role.snowflake_staging_s3_reader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListHivePartitionsUnderPrefix"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = var.staging_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${local.prefix_trimmed}",
              "${local.prefix_trimmed}/",
              "${local.prefix_trimmed}/*"
            ]
          }
        }
      },
      {
        Sid    = "GetParquetObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${var.staging_bucket_arn}/${local.prefix_trimmed}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "snowflake_glue_catalog_read" {
  name = "${var.environment}-${var.project}-snowflake-glue-catalog-read"
  role = aws_iam_role.snowflake_staging_s3_reader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadGlueCatalogForIceberg"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions"
        ]
        Resource = [
          "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:catalog",
          "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:database/${var.glue_database_name}",
          "arn:aws:glue:${var.aws_region}:${var.aws_account_id}:table/${var.glue_database_name}/*"
        ]
      }
    ]
  })
}
