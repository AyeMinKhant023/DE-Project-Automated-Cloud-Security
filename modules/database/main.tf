# 1. Database Security Group (Zero Trust: Port 3306 strictly from App SG)
resource "aws_security_group" "db_sg" {
  name        = "Database-Security-Group"
  description = "Allow MySQL traffic strictly from App Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EC2 App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Local response egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database-Security-Group"
  }
}

# 2. Encrypted RDS MySQL Instance
resource "aws_db_instance" "database" {
  identifier             = "de-project-mysql-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "DEProjectDB"
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Cryptographic Governance (Phase 3)
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "DE-Project-Encrypted-MySQL"
  }
}
