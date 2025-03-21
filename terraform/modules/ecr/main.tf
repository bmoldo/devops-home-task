resource "aws_ecr_repository" "app_repository" {
  name                 = "${var.repository_name}-${var.environment}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.repository_name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecr_lifecycle_policy" "app_lifecycle_policy" {
  repository = aws_ecr_repository.app_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${var.keep_image_count} images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = var.keep_image_count
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy for cross-account access and environment promotion
resource "aws_ecr_repository_policy" "app_repository_policy" {
  repository = aws_ecr_repository.app_repository.name
  
  # This policy enables promotion between environments
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat([
      {
        Sid       = "AllowPullPush",
        Effect    = "Allow",
        Principal = {
          "AWS" = "arn:aws:iam::${var.account_id}:root"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ],
    # Optional additional statements for cross-environment promotion
    var.environment == "dev" ? [{
      Sid    = "AllowPullFromQA",
      Effect = "Allow",
      Principal = {
        "AWS" = lookup(var.environment_principals, "qa", var.account_id)
      },
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }] : [],
    var.environment == "qa" ? [{
      Sid    = "AllowPullFromProd",
      Effect = "Allow",
      Principal = {
        "AWS" = lookup(var.environment_principals, "prod", var.account_id)
      },
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }] : [])
  })
}