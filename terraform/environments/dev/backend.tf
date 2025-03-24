terraform {
  backend "s3" {
    bucket         = "terraform-state-dev-070503547773"
    key            = "terraform/dev/terraform.tfstate"
    region         = "eu-west-1" 
    encrypt        = true
    dynamodb_table = "terraform-locks-dev"
  }
}