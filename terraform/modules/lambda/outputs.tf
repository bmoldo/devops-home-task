output "function_name" {
  value       = can(aws_lambda_function.function[0]) ? aws_lambda_function.function[0].function_name : null
  description = "The name of the Lambda function"
}

output "function_arn" {
  value       = can(aws_lambda_function.function[0]) ? aws_lambda_function.function[0].arn : null
  description = "The ARN of the Lambda function"
}

output "invoke_arn" {
  value       = can(aws_lambda_function.function[0]) ? aws_lambda_function.function[0].invoke_arn : null
  description = "The Invoke ARN of the Lambda function"
}

output "security_group_id" {
  description = "The ID of the Lambda function's security group"
  value       = length(var.vpc_config != null ? var.vpc_config.security_group_ids : []) > 0 ? var.vpc_config.security_group_ids[0] : null
}