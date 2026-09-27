# 1. Main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "DE-Project-VPC"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DE-Project-IGW"
  }
}

# 3. Public Subnets (ALB & NAT Gateway)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${var.availability_zones[count.index]}"
  }
}

# 4. Private App Subnets (EC2 Compute nodes - zero public IPs)
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private-App-Subnet-${var.availability_zones[count.index]}"
  }
}

# 5. Private DB Subnets (Multi-AZ RDS)
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private-DB-Subnet-${var.availability_zones[count.index]}"
  }
}

# 6. Elastic IP & NAT Gateway in Public Subnet 1a
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "DE-Project-NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "DE-Project-NAT"
  }
}

# 7. Route Tables
# A. Public Route Table (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# B. Private App Route Table (0.0.0.0/0 -> NAT Gateway)
resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private-App-Route-Table"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app_rt.id
}

# C. Private DB Route Table (Local VPC routing only, isolated from Internet)
resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private-DB-Route-Table"
  }
}

resource "aws_route_table_association" "private_db" {
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db_rt.id
}

# 8. RDS DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "de-project-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "DE-Project-DB-Subnet-Group"
  }
}
