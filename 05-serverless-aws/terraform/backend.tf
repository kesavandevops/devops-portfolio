terraform {
  backend "s3" {
    bucket         = "my-terraform-state-file-ap-south-1"  # <-- Replace
    key            = "serverless-api/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"                # <-- Replace
    encrypt        = true
  }
}
