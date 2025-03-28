output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
}

output "db_name" {
  description = "Database name"
  value       = var.rds_config.database_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = length(module.api_gateway) > 0 ? "${module.api_gateway[0].invoke_url}${var.api_gateway_config.stage_name}/" : null
}


output "app_data_bucket" {
  description = "The S3 bucket for application data (user queries)"
  value       = module.s3.bucket_name
}

output "lambda_packages_bucket" {
  description = "The S3 bucket for Lambda deployment packages"
  value       = aws_s3_bucket.lambda_packages.bucket
}

output "api_url" {
  description = "API Gateway endpoint if available"
  value       = length(module.api_gateway) > 0 ? module.api_gateway[0].api_url : ""
}