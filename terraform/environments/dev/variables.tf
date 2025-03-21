variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "ecr_config" {
  description = "Configuration for ECR repository"
  type = object({
    repository_name      = string
    image_tag_mutability = string
    scan_on_push         = bool
    keep_image_count     = number
  })
}

variable "vpc_config" {
  description = "Configuration for VPC"
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
  description = "Configuration for RDS instance"
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
  description = "Configuration for Lambda function"
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
  description = "Configuration for S3 bucket"
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
  description = "Configuration for API Gateway"
  type = object({
    name          = string
    endpoint_type = string
    stage_name    = string
    description   = string
  })
}