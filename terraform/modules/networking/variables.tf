variable "rds_sg_id" {
  description = "The security group ID attached to the RDS instance"
  type        = string
}

variable "lambda_sg_id" {
  description = "The security group ID attached to the Lambda function"
  type        = string
}
