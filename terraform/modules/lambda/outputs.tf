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
