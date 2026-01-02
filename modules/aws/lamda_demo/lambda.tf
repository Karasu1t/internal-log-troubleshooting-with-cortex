resource "aws_lambda_function" "lambda_demo" {
  function_name = "lambda_demo_function"
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/src/lambda_function.zip"
  source_code_hash  = filebase64sha256("${path.module}/src/lambda_function.zip")
  role          = aws_iam_role.lambda_exec.arn
}
