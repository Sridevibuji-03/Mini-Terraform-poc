# Private S3 bucket
resource "aws_s3_bucket" "s3_private1" {
  bucket = var.s3_bucket_name   # must be globally unique

  tags = {
    Name       = "${var.project_name}-s3-private1"
    Managed_by = "${var.managed_by}"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "s3_private1" {
  bucket                  = aws_s3_bucket.s3_private1.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "s3_private1" {
  bucket = aws_s3_bucket.s3_private1.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_private1" {
  bucket = aws_s3_bucket.s3_private1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
