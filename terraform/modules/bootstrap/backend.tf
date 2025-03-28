terraform {
  backend "s3" {
    bucket = "terraform-state-<your-org>-<your-repo>"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}
