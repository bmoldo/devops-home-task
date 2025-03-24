resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = var.execution_role_arn

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  handler = var.handler
  runtime = var.runtime

  memory_size = var.memory_size
  timeout     = var.timeout

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
