# Security group for RDS (only EC2 in same SG can connect)
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL traffic only from EC2 SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # EC2 SG we defined earlier
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "tf-rds-sg" })
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = merge(var.tags, { Name = "tf-rds-subnet-group" })
}

# RDS instance (MySQL)
resource "aws_db_instance" "rds" {
  identifier              = "${var.project_name}-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = "admin"
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true

  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  publicly_accessible     = false # only accessible from inside VPC
  multi_az                = false

  tags = merge(var.tags, { Name = "tf-rds" })
}
