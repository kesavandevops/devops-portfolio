# HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

# Lambda integration (single integration reused by routes)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "post_task" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /task"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_task" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /task/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_task" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /task/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Default stage (auto-deploy)
resource "aws_apigatewayv2_stage" "default" {
  api_id   = aws_apigatewayv2_api.http_api.id
  name     = "$default"
  auto_deploy = true
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  # source_arn: allow this API to invoke the function
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
