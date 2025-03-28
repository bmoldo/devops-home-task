module "lock_table" {
  source     = "../modules/lock_table"
  table_name = "terraform-locks-${var.environment}"
}