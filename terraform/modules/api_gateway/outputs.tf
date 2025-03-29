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

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "region" {
  value = data.aws_region.current.name
}

output "api_url" {
  value = length(module.api_gateway) > 0 ? module.api_gateway[0].api_url : null
}

output "api_gateway_url" {
  value = length(module.api_gateway) > 0 ? module.api_gateway[0].api_url : null
}