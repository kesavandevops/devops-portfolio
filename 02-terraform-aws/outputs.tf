output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "Public Subnet A ID"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "Public Subnet B ID"
  value       = aws_subnet.public_b.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web_sg.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.web.public_dns
}

output "s3_bucket_name" {
  description = "S3 bucket name created for demo"
  value       = aws_s3_bucket.demo_bucket.bucket
}

output "s3_user_name" {
  description = "IAM user name with restricted S3 access"
  value       = aws_iam_user.s3_user.name
}

output "s3_user_access_key_id" {
  description = "Access Key ID for IAM user"
  value       = aws_iam_access_key.s3_user_key.id
  sensitive   = true
}

output "s3_user_secret_access_key" {
  description = "Secret Access Key for IAM user"
  value       = aws_iam_access_key.s3_user_key.secret
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "rds_db_name" {
  description = "Database name"
  value       = aws_db_instance.rds.db_name
}
