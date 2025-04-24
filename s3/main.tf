locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  #region      = "us-east-1"
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "new_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = var.tag_name
    Environment = var.tag_env
  }
}