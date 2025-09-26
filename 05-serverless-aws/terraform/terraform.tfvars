# AWS Region
aws_region = "ap-south-1"

# Project name prefix (used for DynamoDB table, Lambda name, API name)
project_name = "serverless-api"

# Relative path to lambda package (from terraform/ dir)
lambda_package_path = "../lambda_package.zip"

# Lambda runtime
lambda_runtime = "python3.9"

# Lambda handler (filename.function)
lambda_handler = "app.lambda_handler"

# Tags applied to all resources
tags = {
  Environment = "dev"
  Project     = "05-serverless-aws"
  Owner       = "Kesavan"
}
