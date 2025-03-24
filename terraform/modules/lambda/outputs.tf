output "function_name" {
  value       = aws_lambda_function.function[0].function_name
  description = "The name of the Lambda function"
  condition   = length(aws_lambda_function.function) > 0
}

output "function_arn" {
  value       = aws_lambda_function.function[0].arn
  description = "The ARN of the Lambda function"
  condition   = length(aws_lambda_function.function) > 0
}

output "invoke_arn" {
  value       = aws_lambda_function.function[0].invoke_arn
  description = "The Invoke ARN of the Lambda function"
  condition   = length(aws_lambda_function.function) > 0
}
