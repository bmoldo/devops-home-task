variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for Lambda function"  # Or leave out the default if you prefer
}

variable "endpoint_type" {
  description = "Endpoint type for the API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "api"
}

variable "lambda_function_arn" {
  description = "Invocation ARN of the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  type        = string
  description = "Description for the API Gateway"
  default     = "API Gateway"
}