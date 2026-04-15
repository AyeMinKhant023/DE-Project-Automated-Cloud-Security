# Force the region to N. Virginia to match your console
provider "aws" {
  region = "us-east-1"
}

# 1. The VPC (The main container)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "DE-Project-VPC"
  }
}

# 2. Internet Gateway (Allows public subnet to connecy to the internet)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "DE-Project-IGW"
  }
}

# 3. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Public-Subnet"
  }
}

# 4. Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-Subnet"
  }
}

# 5. Public Route Table (The 'Map' for the internet)
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

# 6. Route Table Association (Connects the Map to the Public Subnet)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Second Private Subnet (REQUIRED for AWS RDS Database)
resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24" # New IP range
  availability_zone = "us-east-1b" # Different AZ
  tags = {
    Name = "Private-Subnet-2"
  }
}

# 8. Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "DE-Project-NAT-EIP"
  }
}

# 9. NAT Gatway (Placed in Public Subnet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "DE-Project-NAT"
  }
}

# 10. Private Route Table (Roites internet traffic to the NAT)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "Private-Route-Table"
  }
}

# 11. Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}