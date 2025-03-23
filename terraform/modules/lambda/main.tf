data "aws_ecr_repository" "service_repo" {
  name = split("/", var.image_repository)[1]
}

data "aws_ecr_image" "service_image" {
  repository_name = data.aws_ecr_repository.service_repo.name
  image_tag       = "latest"
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = var.execution_role_arn
  
  # Use ZIP package instead of Docker image
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
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