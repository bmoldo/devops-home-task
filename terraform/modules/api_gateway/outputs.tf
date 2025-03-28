output "rest_api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.id
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_deployment.deployment.stage_name
}

output "invoke_url" {
  description = "URL to invoke the API endpoint"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "region" {
  value = data.aws_region.current.name
}

output "api_url" {
  description = "Full invoke URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.deployment.stage_name}"
}

