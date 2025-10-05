# Public SG 
resource "aws_security_group" "public_ec2_sg" {  # ✅ renamed for consistency
  name   = "${var.project_name}-public_ec2-sg"
  vpc_id = aws_vpc.vpc1.id
  description = "Security group for public EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "${var.project_name}-public_ec2-sg"
    Managed_by = var.managed_by
  }
}

# Private SG
resource "aws_security_group" "private_ec2_sg" {  # ✅ renamed
  name   = "${var.project_name}-private_ec2-sg"
  vpc_id = aws_vpc.vpc1.id
  description = "Security group for private EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]  # Use variable for clarity
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "${var.project_name}-private_ec2-sg"
    Managed_by = var.managed_by
  }
}
