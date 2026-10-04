terraform {
  backend "s3" {
    bucket         = "arrise-devops-tfstate-329231175590-ap-south-1"
    key            = "task1/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "arrise-devops-terraform-locks"
    use_lockfile   = true
  }
}
