variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "endpoint_type" {
  description = "Endpoint type of the API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "dev"
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}