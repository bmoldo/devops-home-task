terraform {
  backend "s3" {
    bucket         = "terraform-state-dev"
    key            = "terraform/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-dev"
  }
}