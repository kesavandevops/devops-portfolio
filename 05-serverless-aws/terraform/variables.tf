variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "serverless-api"
}

# path to the zip file *relative to this terraform module directory*
variable "lambda_package_path" {
  description = "Path to lambda zip package (relative to terraform/ directory)"
  type        = string
  default     = "../lambda_package.zip"
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
  default     = "app.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "05-serverless-aws"
    Owner   = "Kesavan"
  }
}
