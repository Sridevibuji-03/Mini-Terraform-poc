terraform {
  backend "s3" {
    bucket  = "terraform-s3-remote-backend-statefile"           
    key     = "Miniproject/terraform.tfstate"  
    region  = "us-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}
