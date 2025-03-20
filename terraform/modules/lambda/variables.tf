variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "image_uri" {
  description = "URI of the container image"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the execution role for the Lambda function"
  type        = string
}

variable "memory_size" {
  description = "Memory size for the Lambda function (MB)"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Timeout for the Lambda function (seconds)"
  type        = number
  default     = 30
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}