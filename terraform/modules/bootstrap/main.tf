module "lock_table" {
  source     = "../modules/lock_table"
  table_name = "terraform-locks-${var.environment}"
  tags = {
    Project     = "user-api"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
