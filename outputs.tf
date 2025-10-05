output "public_ec2_public_ip" {
  description = "Public IP address of the public EC2 instance"
  value = aws_instance.ec2-public1.public_ip
}

output "private_ec2_private_ip" {
  description = "Private IP address of the private EC2 instance"
  value = aws_instance.ec2-private1.private_ip
}

 # Output VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc1.id
}

# S3 bucket name
output "s3_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = aws_s3_bucket.s3_private1.bucket
}
