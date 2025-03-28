output "lock_table_name" {
  description = "Name of the DynamoDB lock table used by Terraform"
  value       = aws_dynamodb_table.terraform_lock_table.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB lock table used by Terraform"
  value       = aws_dynamodb_table.terraform_lock_table.arn
}
