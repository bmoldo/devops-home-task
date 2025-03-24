resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = var.execution_role_arn
  
  # When use_s3_source is true, use S3 for the source
  s3_bucket     = var.use_s3_source ? var.s3_bucket : null
  s3_key        = var.use_s3_source ? var.s3_key : null
  
  # When use_s3_source is false, use the local file
  filename      = var.use_s3_source ? null : var.lambda_zip_path
  
  # Only calculate source_code_hash for local files
  source_code_hash = var.use_s3_source ? null : filebase64sha256(var.lambda_zip_path)
  
  handler          = var.handler
  runtime          = var.runtime
  
  memory_size      = var.memory_size
  timeout          = var.timeout
  
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }
  
  environment {
    variables = var.environment_variables
  }
  
  tags = merge({
    Name        = var.function_name
    Environment = var.environment
  }, var.tags)
  
  lifecycle {
    ignore_changes = var.use_s3_source ? [] : [filename, source_code_hash]
  }
}