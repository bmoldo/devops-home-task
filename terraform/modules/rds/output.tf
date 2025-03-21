output "instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "The master username for the database"
  value       = var.username
}

output "port" {
  description = "The database port"
  value       = 5432
}

output "secret_arn" {
  description = "The ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "connection_string" {
  description = "The connection string for the database"
  value       = "postgresql://${var.username}:${random_password.db_password.result}@${aws_db_instance.main.endpoint}/${var.database_name}"
  sensitive   = true
}