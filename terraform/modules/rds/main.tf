# Subnet group for RDS instance
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-${var.identifier}-subnet-group"
  description = "Database subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.environment}-${var.identifier}-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Parameter group for PostgreSQL
resource "aws_db_parameter_group" "main" {
  name        = "${var.environment}-${var.identifier}-pg"
  family      = "postgres${replace(var.engine_version, ".", "")}"
  description = "Parameter group for ${var.identifier} PostgreSQL ${var.engine_version}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries taking longer than 1 second
  }

  tags = {
    Name        = "${var.environment}-${var.identifier}-pg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# RDS instance
resource "aws_db_instance" "main" {
  identifier                  = var.identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = "gp2"
  storage_encrypted           = true
  username                    = var.username
  password                    = var.password
  db_name                     = var.database_name
  parameter_group_name        = aws_db_parameter_group.main.name
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = var.security_group_ids
  multi_az                    = var.multi_az
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  deletion_protection         = var.deletion_protection
  publicly_accessible         = false
  copy_tags_to_snapshot       = true
  auto_minor_version_upgrade  = true
  performance_insights_enabled = var.performance_insights_enabled

  tags = {
    Name        = var.identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "dev-db-password"
  description = "Database credentials for ${var.identifier}"
  
  tags = {
    Name        = "${var.environment}-${var.identifier}-credentials"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username          = var.username
    password          = var.password
    engine            = var.engine
    host              = aws_db_instance.main.address
    port              = aws_db_instance.main.port
    dbname            = var.database_name
    connection_string = "postgresql://${var.username}:${var.password}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${var.database_name}"
  })
}