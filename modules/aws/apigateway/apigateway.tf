# HTTP API
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.environment}-${var.project}-http-api"
  protocol_type = "HTTP"
}

# Lambda integration
resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  integration_uri    = var.lambda_function_arn
  integration_method = "POST"
}

# Route: POST /lambda
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /lambda"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.environment
  auto_deploy = true
}

# Permission: API Gateway -> Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowHTTPAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
