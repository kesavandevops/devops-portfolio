resource "aws_iam_user" "s3_user" {
  name = "${var.project_name}-s3-user"
  tags = merge(var.tags, { Name = "tf-s3-user" })
}

resource "aws_iam_policy" "s3_user_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow ${var.project_name}-s3-user to access only project S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.demo_bucket.arn,
          "${aws_s3_bucket.demo_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_user_policy.arn
}

# Access keys for programmatic access (use carefully in demo!)
resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}
