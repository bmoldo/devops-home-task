terraform {
  backend "s3" {
    bucket = "terraform-state-bmoldo-devops-home-task"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}
