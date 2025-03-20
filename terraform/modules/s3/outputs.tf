output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.query_results.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.query_results.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.query_results.bucket
}