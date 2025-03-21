output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "invoke_arn" {
  description = "Invocation ARN of the Lambda function"
  value       = aws_lambda_function.function.invoke_arn
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = var.execution_role_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN (including version) of the Lambda function"
  value       = aws_lambda_function.function.qualified_arn
}