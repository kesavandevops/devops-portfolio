variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR range allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type = map(string)
  default = {
    "Project" = "02-terraform-aws"
    "Owner"   = "Kesavan"
  }
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "tf-demo"
}
