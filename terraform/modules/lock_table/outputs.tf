output "lock_table_name" {
  value       = aws_dynamodb_table.terraform_lock_table.name
  description = "DynamoDB table name used for state locking"
}

output "lock_table_arn" {
  value       = aws_dynamodb_table.terraform_lock_table.arn
  description = "DynamoDB table ARN"
}
