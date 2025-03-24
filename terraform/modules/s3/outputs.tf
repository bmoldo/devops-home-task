output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}


# User API bucket outputs
output "user_api_bucket_name" {
  description = "The name of the User API S3 bucket"
  value       = aws_s3_bucket.user_api.id
}

output "user_api_bucket_arn" {
  description = "The ARN of the User API S3 bucket"
  value       = aws_s3_bucket.user_api.arn
}

# Lambda zip bucket outputs
output "lambda_zip_bucket_name" {
  description = "The name of the Lambda zip S3 bucket"
  value       = aws_s3_bucket.lambda_zip.id
}

output "lambda_zip_bucket_arn" {
  description = "The ARN of the Lambda zip S3 bucket"
  value       = aws_s3_bucket.lambda_zip.arn
}
