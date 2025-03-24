# Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.environment}-${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.app_name}-lambda-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Lambda ECR access policy
resource "aws_iam_policy" "lambda_ecr_policy" {
  name        = "${var.environment}-${var.app_name}-lambda-ecr-policy"
  description = "Policy for Lambda to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = var.ecr_repository_arn
      },
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Lambda S3 access policy
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${var.environment}-${var.app_name}-lambda-s3-policy"
  description = "Policy for Lambda to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Lambda VPC access policy
resource "aws_iam_policy" "lambda_vpc_policy" {
  name        = "${var.environment}-${var.app_name}-lambda-vpc-policy"
  description = "Policy for Lambda to access VPC resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policies to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_ecr_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_vpc_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CI/CD role (for GitHub Actions or other CI/CD systems)
resource "aws_iam_role" "cicd_role" {
  name = "${var.environment}-${var.app_name}-cicd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.app_name}-cicd-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CI/CD ECR push policy
resource "aws_iam_policy" "cicd_ecr_policy" {
  name        = "${var.environment}-${var.app_name}-cicd-ecr-policy"
  description = "Policy for CI/CD to push to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Effect   = "Allow"
        Resource = var.ecr_repository_arn
      },
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to CI/CD role
resource "aws_iam_role_policy_attachment" "cicd_ecr_attachment" {
  role       = aws_iam_role.cicd_role.name
  policy_arn = aws_iam_policy.cicd_ecr_policy.arn
}

# Optional: DevOps admin role
resource "aws_iam_role" "devops_admin_role" {
  name = "${var.environment}-devops-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-devops-admin-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Get current account ID
data "aws_caller_identity" "current" {}

# Attach AdministratorAccess policy to DevOps admin role
resource "aws_iam_role_policy_attachment" "devops_admin_attachment" {
  role       = aws_iam_role.devops_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}