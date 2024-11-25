terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "terraform-backend-grid-ysolis"
  tags = {
    Name = "my-s3-bucket"
  }
}
