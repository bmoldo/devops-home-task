variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "image_uri" {
  description = "ECR image URI for the Lambda function"
  type        = string
  
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for Lambda execution"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB assigned to the Lambda function"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Maximum execution time for the Lambda function in seconds"
  type        = number
  default     = 30
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

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "image_repository" {
  description = "The ECR repository name/path for the Lambda function"
  type        = string
  default     = ""
}