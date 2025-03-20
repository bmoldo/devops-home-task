variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Lambda access"
  type        = string
}