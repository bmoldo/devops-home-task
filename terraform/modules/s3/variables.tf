variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether versioning is enabled for the bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    id              = string
    enabled         = bool
    prefix          = string
    expiration_days = number
  }))
  default = []
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}