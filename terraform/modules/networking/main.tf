# Allow Lambda to reach RDS

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.vpc.default_security_group_id
  source_security_group_id = module.vpc.lambda_security_group_id
  description              = "Allow Lambda to connect to RDS on port 5432"
}