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

# VPC for the application
module "vpc" {
  source = "../../modules/vpc"

  vpc_config = {
    cidr_block         = var.vpc_config.cidr_block
    azs                = var.vpc_config.azs
    public_subnets     = var.vpc_config.public_subnets
    private_subnets    = var.vpc_config.private_subnets
    enable_nat_gateway = var.vpc_config.enable_nat_gateway
    single_nat_gateway = var.vpc_config.single_nat_gateway
  }

  environment = var.environment
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

  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  environment = var.environment
}

# S3 Bucket for application data
module "s3" {
  source = "../../modules/s3"

  bucket_name        = var.s3_config.bucket_name
  versioning_enabled = var.s3_config.versioning_enabled
  lifecycle_rules    = var.s3_config.lifecycle_rules

  environment = var.environment
}

# S3 Bucket for Lambda deployment packages
resource "aws_s3_bucket" "lambda_packages" {
  bucket = "lambda-packages-${var.environment}-${var.account_id}"

  tags = merge(local.common_tags, {
    Name = "Lambda Deployment Packages - ${var.environment}"
  })
}

# Configure versioning for Lambda packages bucket
resource "aws_s3_bucket_versioning" "lambda_packages_versioning" {
  bucket = aws_s3_bucket.lambda_packages.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure encryption for Lambda packages bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_packages_encryption" {
  bucket = aws_s3_bucket.lambda_packages.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for Lambda packages bucket
resource "aws_s3_bucket_public_access_block" "lambda_packages_block_public_access" {
  bucket = aws_s3_bucket.lambda_packages.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add lifecycle rules for Lambda packages bucket
resource "aws_s3_bucket_lifecycle_configuration" "lambda_packages_lifecycle" {
  bucket = aws_s3_bucket.lambda_packages.id

  rule {
    id     = "expire-old-packages"
    status = "Enabled"

    filter {
      prefix = "lambda/"
    }

    # Keep previous Lambda versions for 30 days
    expiration {
      days = 30
    }

    # Add noncurrent version expiration
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# Attach policies to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# S3 access for Lambda
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "lambda-s3-access-${var.environment}"
  description = "Allow Lambda to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = [
          "${module.s3.bucket_arn}",
          "${module.s3.bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

# Lambda CloudWatch Logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_config.function_name}-${local.env_suffix}"
  retention_in_days = var.lambda_config.log_retention_in_days
  tags              = local.common_tags
}

# Lambda function for API
module "lambda" {
  source = "../../modules/lambda"

  function_name      = "${var.lambda_config.function_name}-${local.env_suffix}"
  execution_role_arn = aws_iam_role.lambda_execution_role.arn

  # Use the zip deployment instead of Docker image
  lambda_zip_path = var.lambda_zip_path # Will default to "lambda_deployment_package.zip" if not provided
  handler         = var.lambda_config.handler
  runtime         = var.lambda_config.runtime

  memory_size = var.lambda_config.memory_size
  timeout     = var.lambda_config.timeout

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.vpc.lambda_security_group_id]
  }

  environment_variables = {
    for k, v in merge(var.lambda_config.environment_variables, {
      DATABASE_URL   = "postgresql://${var.rds_config.username}:${random_password.db_password.result}@${module.rds.endpoint}/${var.rds_config.database_name}"
      S3_BUCKET_NAME = module.s3.bucket_name
    }) : k => v if !contains(["AWS_REGION", "AWS_LAMBDA_FUNCTION_NAME"], k)
  }

  environment = var.environment
}

# Random password for database if needed
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
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

  depends_on = [module.lambda]
}