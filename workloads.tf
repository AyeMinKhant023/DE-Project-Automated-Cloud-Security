# ==========================================
# 1. SECURITY GROUPS (Zero Trust Firewalls)
# ==========================================

# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name        = "Web-Server-SG"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from within the VPC (Internal testing)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] 
  }

  # Allow all outbound traffic (so it can reach the internet via NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group (Highly Restricted!)
resource "aws_security_group" "db_sg" {
  name        = "Database-SG"
  description = "Allow MySQL traffic strictly from Web Server"
  vpc_id      = aws_vpc.main.id

  # ONLY accept traffic on port 3306 from the Web Server Security Group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] 
  }
}

# ==========================================
# 2. EC2 INSTANCE (The Web Server)
# ==========================================

# Dynamically grab the latest Amazon Linux 2023 Image
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Private-Web-Server"
  }
}

# ==========================================
# 3. RDS INSTANCE (The Database)
# ==========================================

# Group the two private subnets together for the Database
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "de-project-db-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "database" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "DEProjectDB"
  username               = "admin"
  password               = "SuperSecurePass123!" # We will secure this later
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true # Makes it easy to delete for your project
}

