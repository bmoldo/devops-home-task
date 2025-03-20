resource "aws_lambda_function" "main" {
  function_name = "${var.environment}-${var.function_name}"
  role          = var.execution_role_arn
  package_type  = "Image"
  image_uri     = var.image_uri
  memory_size   = var.memory_size
  timeout       = var.timeout

  vpc_config {
    subnet_ids         = var.vpc_config.subnet_ids
    security_group_ids = var.vpc_config.security_group_ids
  }

  environment {
    variables = var.environment_variables
  }

  tags = {
    Name        = "${var.environment}-${var.function_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-${var.function_name}-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}