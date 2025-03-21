provider "aws" {
  region = var.aws_region
}

locals {
  env_suffix = var.environment
  common_tags = {
    Environment = var.environment
    Project     = "user-api"
    ManagedBy   = "Terraform"
  }
}

# ECR Repository for Docker images
module "ecr" {
  source = "../../modules/ecr"
  
  repository_name      = var.ecr_config.repository_name
  environment          = var.environment
  account_id           = var.account_id
  image_tag_mutability = var.ecr_config.image_tag_mutability
  scan_on_push         = var.ecr_config.scan_on_push
  keep_image_count     = var.ecr_config.keep_image_count
  
  # We're using a single-account setup, so we don't need environment principals
}

# VPC for the application
module "vpc" {
  source = "../../modules/vpc"
  
  cidr_block         = var.vpc_config.cidr_block
  azs                = var.vpc_config.azs
  public_subnets     = var.vpc_config.public_subnets
  private_subnets    = var.vpc_config.private_subnets
  enable_nat_gateway = var.vpc_config.enable_nat_gateway
  single_nat_gateway = var.vpc_config.single_nat_gateway
  environment        = var.environment
  
  tags = local.common_tags
}

# RDS Database
module "rds" {
  source = "../../modules/rds"
  
  identifier              = "${var.rds_config.identifier}-${local.env_suffix}"
  engine                  = var.rds_config.engine
  engine_version          = var.rds_config.engine_version
  instance_class          = var.rds_config.instance_class
  allocated_storage       = var.rds_config.allocated_storage
  max_allocated_storage   = var.rds_config.max_allocated_storage
  username                = var.rds_config.username
  database_name           = var.rds_config.database_name
  backup_retention_period = var.rds_config.backup_retention_period
  deletion_protection     = var.rds_config.deletion_protection
  multi_az                = var.rds_config.multi_az
  skip_final_snapshot     = var.rds_config.skip_final_snapshot
  maintenance_window      = var.rds_config.maintenance_window
  backup_window           = var.rds_config.backup_window
  
  subnet_ids              = module.vpc.private_subnet_ids
  vpc_security_group_ids  = [module.vpc.default_security_group_id]
  
  environment             = var.environment
  tags                    = local.common_tags
}

# S3 Bucket for application data
module "s3" {
  source = "../../modules/s3"
  
  bucket_name        = var.s3_config.bucket_name
  versioning_enabled = var.s3_config.versioning_enabled
  lifecycle_rules    = var.s3_config.lifecycle_rules
  
  environment        = var.environment
  tags               = local.common_tags
}

# Lambda function for API
module "lambda" {
  source = "../../modules/lambda"
  
  function_name         = "${var.lambda_config.function_name}-${local.env_suffix}"
  runtime               = var.lambda_config.runtime
  memory_size           = var.lambda_config.memory_size
  timeout               = var.lambda_config.timeout
  log_retention_in_days = var.lambda_config.log_retention_in_days
  handler               = var.lambda_config.handler
  environment_variables = merge(var.lambda_config.environment_variables, {
    DATABASE_URL  = module.rds.connection_string
    S3_BUCKET_NAME = module.s3.bucket_name
  })
  
  subnet_ids           = module.vpc.private_subnet_ids
  security_group_ids   = [module.vpc.lambda_security_group_id]
  
  environment          = var.environment
  tags                 = local.common_tags
  
  depends_on = [module.rds, module.s3]
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api_gateway"
  
  name          = "${var.api_gateway_config.name}-${local.env_suffix}"
  endpoint_type = var.api_gateway_config.endpoint_type
  stage_name    = var.api_gateway_config.stage_name
  description   = var.api_gateway_config.description
  
  lambda_function_name = module.lambda.function_name
  lambda_function_arn  = module.lambda.function_arn
  
  environment = var.environment
  tags        = local.common_tags
  
  depends_on = [module.lambda]
}