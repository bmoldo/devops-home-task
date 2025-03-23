variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the Lambda execution role"
  type        = string
}

variable "memory_size" {
  description = "The amount of memory to allocate to the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The timeout period for the Lambda function in seconds"
  type        = number
  default     = 3
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_handler.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package ZIP file"
  type        = string
  default     = "lambda_deployment_package.zip"
}