variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
    azs        = list(string)
  })
}