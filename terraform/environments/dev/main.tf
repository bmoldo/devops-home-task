provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOpsHomeTask"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

# Store the password in Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name = "rds/${var.environment}/password"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_password.result
}

# VPC Module
module "vpc" {
  source      = "../../modules/vpc"
  environment = var.environment
  vpc_config  = var.vpc_config
}

# ECR Repository Module
module "ecr" {
  source = "../../modules/ecr"

  environment     = var.environment
  repository_name = "${var.environment}-${var.app_name}"
  image_tag_mutability = "MUTABLE"
  scan_on_push    = true
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment        = var.environment
  app_name           = var.app_name
  ecr_repository_arn = module.ecr.repository_arn
  s3_bucket_name     = module.s3.bucket_name
}

# S3 Module for query results
module "s3" {
  source = "../../modules/s3"

  environment = var.environment
  bucket_name = var.s3_config.bucket_name != "" ? var.s3_config.bucket_name : "${var.environment}-${var.app_name}-queries-${random_string.bucket_suffix.result}"
  versioning_enabled = var.s3_config.versioning_enabled
  lifecycle_rules    = var.s3_config.lifecycle_rules
}

# Random string for S3 bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment           = var.environment
  identifier            = var.rds_config.identifier
  engine                = var.rds_config.engine
  engine_version        = var.rds_config.engine_version
  instance_class        = var.rds_config.instance_class
  allocated_storage     = var.rds_config.allocated_storage
  max_allocated_storage = var.rds_config.max_allocated_storage
  username              = var.rds_config.username
  password              = random_password.rds_password.result
  database_name         = var.rds_config.database_name
  subnet_ids            = module.vpc.private_subnet_ids
  security_group_ids    = [module.vpc.rds_security_group_id]
  multi_az              = var.rds_config.multi_az
  skip_final_snapshot   = var.rds_config.skip_final_snapshot
  maintenance_window    = var.rds_config.maintenance_window
  backup_window         = var.rds_config.backup_window
  backup_retention_period = var.rds_config.backup_retention_period
  deletion_protection   = var.rds_config.deletion_protection
}

# Lambda Function Module
module "lambda" {
  source = "../../modules/lambda"

  environment   = var.environment
  function_name = var.lambda_config.function_name
  image_uri     = "${module.ecr.repository_url}:latest"
  memory_size   = var.lambda_config.memory_size
  timeout       = var.lambda_config.timeout
  execution_role_arn = module.iam.lambda_execution_role_arn

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.vpc.lambda_security_group_id]
  }

  environment_variables = merge(var.lambda_config.environment_variables, {
    DATABASE_URL = "postgresql://${var.rds_config.username}:${random_password.rds_password.result}@${module.rds.db_endpoint}/${var.rds_config.database_name}"
  })
}

# API Gateway Module
module "api_gateway" {
  source = "../../modules/api_gateway"

  environment         = var.environment
  name                = var.api_gateway_config.name
  endpoint_type       = var.api_gateway_config.endpoint_type
  stage_name          = var.api_gateway_config.stage_name
  lambda_function_arn = module.lambda.function_arn
  lambda_function_name= module.lambda.function_name
}
