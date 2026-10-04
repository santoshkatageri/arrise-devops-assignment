terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = "arrise-devops-tfstate-329231175590-ap-south-1"
  tags = {
    Name        = "arrise-devops-terraform-state"
    Environment = "dev"
    Owner       = "devops"
  }
}

module "dynamodb_lock_table" {
  source = "./modules/dynamodb_lock_table"

  table_name = "arrise-devops-terraform-locks"
  tags = {
    Environment = "dev"
    Owner       = "devops"
  }
}
