// General settings
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "api_gw_app"
}

// VPC settings
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block        = string
    azs               = list(string)
    public_subnets    = list(object({
      cidr = string
      az   = string
    }))
    private_subnets   = list(object({
      cidr = string
      az   = string
    }))
    enable_nat_gateway = bool
    single_nat_gateway = bool
  })
}

// RDS settings
variable "rds_config" {
  type = object({
    identifier            = string
    engine                = string
    engine_version        = string
    instance_class        = string
    allocated_storage     = number
    max_allocated_storage = number
    username              = string
    database_name         = string
    backup_retention_period = number
    deletion_protection   = bool
    multi_az              = bool
    skip_final_snapshot   = bool
    maintenance_window    = string
    backup_window         = string
    # Note: password is not in this list
  })
  description = "Configuration for RDS instance"
}
// Lambda settings
variable "lambda_config" {
  description = "Lambda function configuration"
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

// S3 settings
variable "s3_config" {
  description = "S3 bucket configuration"
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

// API Gateway settings
variable "api_gateway_config" {
  description = "API Gateway configuration"
  type = object({
    name          = string
    description   = string
    endpoint_type = string
    stage_name    = string
  })
}

// ECR settings (if used)
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR"
  type        = string
  default     = ""
}

variable "ecr_scan_on_push" {
  description = "Enable scan on push for ECR"
  type        = bool
  default     = true
}
