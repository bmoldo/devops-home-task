terraform {
  backend "s3" {
    bucket  = "terraform-state--${var.repo_name}-dev"
    key     = "terraform/${var.environment}/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks-${var.environment}"
  }
}