output "endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.main.username
}

output "password" {
  value     = var.password
  sensitive = true
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.main.db_name
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}