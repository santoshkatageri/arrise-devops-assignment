terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0, < 7.0" }
  }
  backend "s3" {
    bucket         = "arrise-devops-tfstate-329231175590-ap-south-1"
    key            = "task3/account-a/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "arrise-devops-terraform-locks"
    use_lockfile   = true
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.account_a_id]
}
