output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_execution_arn" {
  description = "Execution ARN of the REST API"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "deployment_stage_name" {
  description = "Name of the deployment stage"
  value       = aws_api_gateway_deployment.main.stage_name
}

output "invoke_url" {
  description = "Invocation URL of the API Gateway"
  value       = aws_api_gateway_deployment.main.invoke_url
}