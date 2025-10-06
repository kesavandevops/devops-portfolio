terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Toggle CI-safe provider configuration (true in Jenkins, false locally)
variable "ci_mode" {
  description = "Enable CI-safe provider config by skipping slow validations"
  type        = bool
  default     = true
}

provider "aws" {
  region = var.aws_region

  # CI-only relaxations: set ci_mode=true in Jenkins to bypass slow checks
  skip_credentials_validation = var.ci_mode
  skip_metadata_api_check     = var.ci_mode
  skip_region_validation      = var.ci_mode

  # Prefer regional STS endpoints to avoid global endpoint latency in CI
  sts_regional_endpoints = "regional"
}
