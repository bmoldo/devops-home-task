output "bucket_name" {
  value = aws_s3_bucket.user_api.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.user_api.arn
}