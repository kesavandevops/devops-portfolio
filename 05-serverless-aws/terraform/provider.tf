terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-file-ap-south-1"  # <-- Replace
    key            = "serverless-api/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"  # <-- Replace
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
