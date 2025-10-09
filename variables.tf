variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default = "DevOps-Terraform"
}
variable "managed_by" {
   default = "BICS-DevOps"
}

variable "instance_name"{
    description = "EC2 instance type"
    type        = string
    default     = "t2.micro"
}

variable "s3_bucket_name"{
    description = "Name of the private S3 bucket"
    type        = string
}

# Existing EC2 key pair name
variable "key_pair_name" {
  description = "Existing EC2 key pair name to use for SSH access"
  type        = string
  default     = "terraform-poc-public-key"
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public subnet CIDR
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Private subnet CIDR
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

# Availability zone
variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-west-1a"
}

variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "private_key_content" {
  description = "Private key used for SSH or provisioning"
  type        = string
  sensitive   = true
}
