resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = var.execution_role_arn
  image_uri     = var.image_uri
  package_type  = "Image"
  
  memory_size   = var.memory_size
  timeout       = var.timeout
  
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
  
  lifecycle {
    ignore_changes = [image_uri]  # Ignore image changes as they will be updated by the CI/CD pipeline
  }
  
  tags = merge({
    Name        = var.function_name
    Environment = var.environment
  }, var.tags)
}