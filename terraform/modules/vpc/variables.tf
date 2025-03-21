variable "vpc_config" {
  description = "Configuration for the VPC"
  type = object({
    cidr_block         = string
    azs                = list(string)
    public_subnets     = list(map(string))
    private_subnets    = list(map(string))
    enable_nat_gateway = bool
    single_nat_gateway = bool
  })
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}