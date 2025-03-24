locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "vpc-${var.environment}"
    },
    local.common_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "igw-${var.environment}"
    },
    local.common_tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.vpc_config.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_config.public_subnets[count.index].cidr
  availability_zone       = var.vpc_config.public_subnets[count.index].az
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "subnet-public-${var.vpc_config.public_subnets[count.index].az}-${var.environment}"
    },
    local.common_tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.vpc_config.private_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_config.private_subnets[count.index].cidr
  availability_zone       = var.vpc_config.private_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "subnet-private-${var.vpc_config.private_subnets[count.index].az}-${var.environment}"
    },
    local.common_tags
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.vpc_config.enable_nat_gateway ? (var.vpc_config.single_nat_gateway ? 1 : length(var.vpc_config.public_subnets)) : 0

  domain = "vpc"

  tags = merge(
    {
      Name = "eip-nat-${count.index}-${var.environment}"
    },
    local.common_tags
  )
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count = var.vpc_config.enable_nat_gateway ? (var.vpc_config.single_nat_gateway ? 1 : length(var.vpc_config.public_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "nat-${count.index}-${var.environment}"
    },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "rt-public-${var.environment}"
    },
    local.common_tags
  )
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count = var.vpc_config.enable_nat_gateway ? (var.vpc_config.single_nat_gateway ? 1 : length(var.vpc_config.private_subnets)) : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.vpc_config.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.vpc_config.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(
    {
      Name = "rt-private-${count.index}-${var.environment}"
    },
    local.common_tags
  )
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.vpc_config.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.vpc_config.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.vpc_config.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# Default Security Group
resource "aws_security_group" "default" {
  name        = "default-sg-${var.environment}"
  description = "Default security group for ${var.environment} environment"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "default-sg-${var.environment}"
    },
    local.common_tags
  )
}

# Lambda Security Group
resource "aws_security_group" "lambda" {
  name        = "lambda-sg-${var.environment}"
  description = "Security group for Lambda functions in ${var.environment} environment"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "lambda-sg-${var.environment}"
    },
    local.common_tags
  )
}