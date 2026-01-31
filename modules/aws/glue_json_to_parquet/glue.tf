resource "aws_s3_object" "glue_script" {
  bucket       = var.script_bucket_id
  key          = "glue/json_to_parquet.py"
  source       = "${path.module}/scripts/json_to_parquet.py"
  content_type = "text/x-python"
}

resource "aws_glue_job" "json_to_parquet" {
  name     = "${var.environment}-${var.project}-json-to-parquet"
  role_arn = aws_iam_role.glue_job_role.arn

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.script_bucket_id}/${aws_s3_object.glue_script.key}"
  }

  default_arguments = {
    "--job-language"                        = "python"
    "--enable-metrics"                      = "true"
    "--enable-continuous-cloudwatch-log"    = "true"
    "--TempDir"                             = "s3://${var.staging_bucket_id}/temp/"
    "--input_path"                          = "s3://${var.raw_bucket_id}/"
    "--output_path"                         = "s3://${var.staging_bucket_id}/logs/parquet/"
  }
}
