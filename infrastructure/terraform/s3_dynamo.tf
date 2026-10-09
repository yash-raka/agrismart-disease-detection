terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- S3 Bucket for Uploaded Images ---
resource "aws_s3_bucket" "images" {
  bucket_prefix = "potato-disease-images-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "images_access" {
  bucket                  = aws_s3_bucket.images.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- DynamoDB Table for Predictions ---
resource "aws_dynamodb_table" "predictions" {
  name           = "PotatoPredictions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
}
