variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "vpc_config" {
  description = "Configuration for the VPC"
  type = object({
    cidr_block         = string
    azs                = list(string)
    public_subnets     = list(map(string))
    private_subnets    = list(map(string))
    enable_nat_gateway = bool
    single_nat_gateway = bool
  })
}

variable "rds_config" {
  description = "Configuration for the RDS database"
  type = object({
    identifier              = string
    engine                  = string
    engine_version          = string
    instance_class          = string
    allocated_storage       = number
    max_allocated_storage   = number
    username                = string
    database_name           = string
    backup_retention_period = number
    deletion_protection     = bool
    multi_az                = bool
    skip_final_snapshot     = bool
    maintenance_window      = string
    backup_window           = string
  })
}

variable "lambda_config" {
  description = "Configuration for the Lambda function"
  type = object({
    function_name         = string
    runtime               = string
    memory_size           = number
    timeout               = number
    log_retention_in_days = number
    handler               = string
    environment_variables = map(string)
  })
}

variable "s3_config" {
  description = "Configuration for the S3 bucket"
  type = object({
    bucket_name        = string
    versioning_enabled = bool
    lifecycle_rules = list(object({
      id              = string
      enabled         = bool
      prefix          = string
      expiration_days = number
    }))
  })
}

variable "api_gateway_config" {
  description = "Configuration for the API Gateway"
  type = object({
    name          = string
    endpoint_type = string
    stage_name    = string
    description   = string
  })
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package ZIP file"
  type        = string
  default     = "lambda_deployment_package.zip"
}

# Lambda S3 source variables
variable "use_s3_source" {
  description = "Whether to use S3 as the source for the Lambda function"
  type        = bool
  default     = false
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key for the Lambda deployment package"
  type        = string
  default     = ""
}

# If you're using ECR in your configuration, you'll also need this
variable "ecr_config" {
  description = "Configuration for the ECR repository"
  type = object({
    repository_name      = string
    image_tag_mutability = string
    scan_on_push         = bool
    keep_image_count     = number
  })
  default = null
}