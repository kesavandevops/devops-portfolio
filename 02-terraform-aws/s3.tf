# get account id to make bucket name unique inside your account
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "demo_bucket" {
  # name unique per account (no random provider needed)
  bucket = "${var.project_name}-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true   # for demo: allows terraform destroy even if bucket not empty
  tags = merge(var.tags, { Name = "tf-s3-bucket" })
}

resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access (recommended)
resource "aws_s3_bucket_public_access_block" "demo_block_public" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
