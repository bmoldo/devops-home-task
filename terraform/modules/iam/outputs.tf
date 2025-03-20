output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD role"
  value       = aws_iam_role.cicd_role.arn
}

output "devops_admin_role_arn" {
  description = "ARN of the DevOps admin role"
  value       = aws_iam_role.devops_admin_role.arn
}