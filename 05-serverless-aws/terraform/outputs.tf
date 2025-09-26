output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
