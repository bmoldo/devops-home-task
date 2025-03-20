variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable scan on push"
  type        = bool
  default     = true
}