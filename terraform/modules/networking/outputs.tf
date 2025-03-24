output "lambda_to_rds_rule_id" {
  description = "ID of the SG rule that allows Lambda to access RDS"
  value       = aws_security_group_rule.allow_lambda_to_rds.id
}
