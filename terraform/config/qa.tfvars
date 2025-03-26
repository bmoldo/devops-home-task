environment = "qa"
aws_region  = "us-east-1"
account_id  = "123456789012" # Replace with your actual AWS account ID

# ECR Configuration
ecr_config = {
  repository_name      = "user-api" # Will become user-api-qa
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  keep_image_count     = 20 # Keep fewer images in QA
}

vpc_config = {
  cidr_block = "10.1.0.0/16" # Different CIDR for QA
  azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = [
    { cidr = "10.1.0.0/24", az = "us-east-1a" },
    { cidr = "10.1.1.0/24", az = "us-east-1b" },
    { cidr = "10.1.2.0/24", az = "us-east-1c" }
  ]
  private_subnets = [
    { cidr = "10.1.10.0/24", az = "us-east-1a" },
    { cidr = "10.1.11.0/24", az = "us-east-1b" },
    { cidr = "10.1.12.0/24", az = "us-east-1c" }
  ]
  enable_nat_gateway = true
  single_nat_gateway = true
}

rds_config = {
  identifier              = "user-api-db"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.small" # Slightly larger for QA
  allocated_storage       = 30            # More storage for QA
  max_allocated_storage   = 100
  username                = "postgres"
  database_name           = "users"
  backup_retention_period = 14   # Longer retention for QA
  deletion_protection     = true # Enable protection for QA
  multi_az                = true # Multi-AZ for better reliability
  skip_final_snapshot     = false
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
}

lambda_config = {
  function_name         = "user-api"
  runtime               = "python3.11"
  memory_size           = 1024 # More memory for QA
  timeout               = 60   # Longer timeout for QA
  log_retention_in_days = 30
  handler               = "main.lambda_handler"
  environment_variables = {
    ENVIRONMENT              = "qa"
    AWS_LAMBDA_FUNCTION_NAME = "user-api"
    AWS_REGION               = "us-east-1"
    AWS_EXECUTION_ENV        = "AWS_Lambda_python3.11"
    API_GATEWAY_BASE_PATH    = "/"
  }
}

s3_config = {
  bucket_name        = "user-queries-qa"
  versioning_enabled = true
  lifecycle_rules = [
    {
      id              = "expire-old-queries"
      enabled         = true
      prefix          = ""
      expiration_days = 180 # Longer retention in QA
    }
  ]
}

api_gateway_config = {
  name          = "user-api"
  endpoint_type = "REGIONAL"
  stage_name    = "qa"
  description   = "API Gateway for User API - QA Environment"
}