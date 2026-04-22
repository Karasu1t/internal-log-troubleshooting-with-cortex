output "lambda_function_arn" {
  value = aws_lambda_function.lambda_demo.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_demo.function_name
}
