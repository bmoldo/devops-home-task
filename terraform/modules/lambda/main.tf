resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = var.execution_role_arn
  
  # Conditionally use S3 or local file for Lambda code
  # If using S3, these values will be used
  s3_bucket     = var.use_s3_source ? var.s3_bucket : null
  s3_key        = var.use_s3_source ? var.s3_key : null
  
  # If using local file, these values will be used
  filename         = var.use_s3_source ? null : var.lambda_zip_path
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
}

# CloudWatch log group for Lambda logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
  tags = merge({
    Name        = "${var.function_name}-logs"
    Environment = var.environment
  }, var.tags)
}