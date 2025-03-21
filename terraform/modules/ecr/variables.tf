variable "repository_name" {
  description = "Base name for the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "keep_image_count" {
  description = "Number of images to keep before expiring"
  type        = number
  default     = 10
}

variable "environment_principals" {
  description = "Map of environment names to AWS account IDs for cross-account access"
  type        = map(string)
  default     = {}
}