# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

# Random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Secrets Manager for RDS credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${local.name_prefix}-db-credentials"
  description             = "Database credentials for ${local.name_prefix}"
  recovery_window_in_days = 0 # Force immediate deletion to avoid conflicts

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
    engine   = "mysql"
    host     = aws_rds_cluster.main.endpoint
    port     = 3306
    dbname   = "bagisto"
  })
}

# RDS Aurora Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${local.name_prefix}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.07.0"
  database_name           = "bagisto"
  master_username         = "admin"
  master_password         = random_password.db_password.result
  backup_retention_period = var.environment == "production" ? 7 : 1
  preferred_backup_window = "07:00-09:00"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = var.environment != "production"
  deletion_protection = var.environment == "production"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-cluster"
  })
}

# RDS Aurora Instances
resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.environment == "production" ? 2 : 1
  identifier         = "${local.name_prefix}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-${count.index}"
  })
}
