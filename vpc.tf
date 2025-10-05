# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr

  tags = {
    Name       = "${var.project_name}-vpc1"
    Managed_by = var.managed_by
  }
}

# Internet Gateway for public subnet access
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name       = "${var.project_name}-igw1"
    Managed_by = var.managed_by
  }
}

# Public subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name       = "${var.project_name}-public-subnet1"
    Managed_by = var.managed_by
  }
}

# Private subnet
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name       = "${var.project_name}-private-subnet1"
    Managed_by = var.managed_by
  }
}

# NAT Gateway to allow private subnet outbound internet access
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name       = "${var.project_name}-nat1"
    Managed_by = var.managed_by
  }

  depends_on = [aws_internet_gateway.igw1] # Ensure IGW exists first
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat1-eip"
    Managed_by = var.managed_by
  }
}

# Public route table
resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name       = "${var.project_name}-public-rt1"
    Managed_by = var.managed_by
  }
}

# Private route table (routes via NAT)
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name       = "${var.project_name}-private-rt1"
    Managed_by = var.managed_by
  }
}

# Route table associations with public rt
resource "aws_route_table_association" "public_subnet1_rt1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt1.id
}

# Route table associations with private rt
resource "aws_route_table_association" "private_subnet1_rt1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt1.id
}
