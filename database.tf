resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds_monitoring_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "rds_monitoring_policy" {
  name        = "rds_monitoring_policy"
  description = "A policy for RDS enhanced monitoring"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Effect = "Allow",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy_attachment" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = aws_iam_policy.rds_monitoring_policy.arn
}

resource "aws_db_subnet_group" "checkday_db_subnet_group" {
  name       = "checkday_db_subnet_group"
  subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]

  tags = {
    Name = "checkday_db_subnet_group"
  }
}

resource "aws_rds_cluster" "checkday_database" {
  cluster_identifier       = "checkday-aurora-db"
  engine                   = "aurora-mysql"
  engine_version           = "5.7.mysql_aurora.2.11.2"
  availability_zones       = var.availability_zones
  database_name            = var.database_name
  master_username          = var.database_username
  master_password          = var.database_password
  backup_retention_period  = 5
  preferred_backup_window  = "07:00-09:00"
  final_snapshot_identifier = "checkday-db-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  db_subnet_group_name     = aws_db_subnet_group.checkday_db_subnet_group.name
}

resource "aws_rds_cluster_instance" "checkday_database_cluster_instance" {
  apply_immediately  = true
  cluster_identifier = aws_rds_cluster.checkday_database.id
  identifier         = "checkday-aurora-db-instance"
  instance_class     = "db.t2.small"
  engine             = aws_rds_cluster.checkday_database.engine
  engine_version     = aws_rds_cluster.checkday_database.engine_version
  db_subnet_group_name = aws_db_subnet_group.checkday_db_subnet_group.name
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  monitoring_interval = 60
}

resource "aws_rds_cluster_endpoint" "checkday_database_cluster_instance_endpoint" {
  cluster_identifier          = aws_rds_cluster.checkday_database.id
  cluster_endpoint_identifier = "static"
  custom_endpoint_type        = "ANY"
}