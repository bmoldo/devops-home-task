# Terraform state bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${var.environment}-${var.account_id}"
  
  tags = {
    Name        = "terraform-state-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"  # Always enable versioning for terraform state
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lambda zip bucket
resource "aws_s3_bucket" "lambda_zip" {
  bucket = "lambda-zip-${var.environment}-${var.account_id}"
  
  tags = {
    Name        = "lambda-zip-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "lambda_zip_versioning" {
  bucket = aws_s3_bucket.lambda_zip.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_zip_encryption" {
  bucket = aws_s3_bucket.lambda_zip.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_zip_lifecycle" {
  bucket = aws_s3_bucket.lambda_zip.id

  rule {
    id     = "expire-old-packages"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Keep previous Lambda versions for 30 days
    expiration {
      days = 30
    }

    # Add noncurrent version expiration
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_zip_block_public_access" {
  bucket = aws_s3_bucket.lambda_zip.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# User API bucket
resource "aws_s3_bucket" "user_api" {
  bucket = var.bucket_name
  
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "user_api_versioning" {
  bucket = aws_s3_bucket.user_api.id
  
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "user_api_encryption" {
  bucket = aws_s3_bucket.user_api.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "user_api_lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.user_api.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      
      filter {
        prefix = rule.value.prefix
      }
      
      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "user_api_block_public_access" {
  bucket = aws_s3_bucket.user_api.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}