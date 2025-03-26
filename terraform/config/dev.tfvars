environment = "dev"
aws_region  = "us-east-1"
account_id  = "070503547773"




vpc_config = {
  cidr_block = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = [
    { cidr = "10.0.0.0/24", az = "us-east-1a" },
    { cidr = "10.0.1.0/24", az = "us-east-1b" },
    { cidr = "10.0.2.0/24", az = "us-east-1c" }
  ]
  private_subnets = [
    { cidr = "10.0.10.0/24", az = "us-east-1a" },
    { cidr = "10.0.11.0/24", az = "us-east-1b" },
    { cidr = "10.0.12.0/24", az = "us-east-1c" }
  ]
  enable_nat_gateway = true
  single_nat_gateway = true
}

api_gateway_config = {
  name          = "user-api"
  endpoint_type = "REGIONAL"
  stage_name    = "dev"
  description   = "User API Gateway for Development Environment"
}

rds_config = {
  identifier              = "user-api"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.micro" # Minimum viable for dev
  allocated_storage       = 20            # Minimum recommended storage
  max_allocated_storage   = 100           # Allow autoscaling
  username                = "postgres"
  database_name           = "users_test"
  backup_retention_period = 7
  deletion_protection     = false
  multi_az                = false # Set to true for production
  skip_final_snapshot     = true  # Set to false for production
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
}

lambda_config = {
  function_name         = "user-api"
  runtime               = "python3.11"
  memory_size           = 512
  timeout               = 30
  log_retention_in_days = 14
  handler               = "main.lambda_handler"
  environment_variables = {
    ENVIRONMENT              = "dev"
    AWS_LAMBDA_FUNCTION_NAME = "user-api"
    AWS_REGION               = "us-east-1"
    AWS_EXECUTION_ENV        = "AWS_Lambda_python3.11"
    API_GATEWAY_BASE_PATH    = "/"
  }
}

s3_config = {
  bucket_name        = "user-queries-dev"
  versioning_enabled = true
  lifecycle_rules = [
    {
      id              = "expire-old-queries"
      enabled         = true
      prefix          = ""
      expiration_days = 90
    }
  ]
}