resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  # The zip file path resolved relative to this module
  filename         = "${path.module}/${var.lambda_package_path}"
  source_code_hash = filebase64sha256("${path.module}/${var.lambda_package_path}")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.tasks.name
    }
  }

  tags = var.tags
}
