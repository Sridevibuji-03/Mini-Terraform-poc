# IAM Role for Private EC2 
resource "aws_iam_role" "private_ec2_role" {
  name = "${var.project_name}-ec2-private1-role"

  # Policy to allow EC2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Private EC2 S3 Access
resource "aws_iam_policy" "s3_private1_policy" {
  name        = "${var.project_name}-s3-private1-policy"
  description = "Allow private EC2 to access S3 bucket (s3_private1)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.s3_private1.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = ["${aws_s3_bucket.s3_private1.arn}/*"]
      }
    ]
  })
}

# Attach the S3 policy to the EC2 IAM role
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.private_ec2_role.name
  policy_arn = aws_iam_policy.s3_private1_policy.arn
}

# Create instance profile for EC2 instances to use IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.private_ec2_role.name
}
