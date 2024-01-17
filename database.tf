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

resource "aws_rds_cluster" "checkday_database" {
  cluster_identifier      = "checkday-aurora-db"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.4"
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.database_username
  master_password         = var.database_password
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  final_snapshot_identifier = "checkday-aurora-db-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  # skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.checkday_db_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.checkday_db_subnet_group.name
  engine_mode = "serverless"
  scaling_configuration {
    min_capacity = 1
    max_capacity = 8
  }
}

# resource "aws_rds_cluster_instance" "checkday_rds_cluster_instance" {
#   count              = 2
#   identifier         = "checkday-aurora-instance-${count.index}"
#   cluster_identifier = aws_rds_cluster.checkday_database.id
#   instance_class     = "db.t2.xlarge"
#   publicly_accessible = true
#   monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
#   db_subnet_group_name = aws_db_subnet_group.checkday_db_subnet_group.name
#   apply_immediately = true
#   availability_zone = var.checkday_rds_instance_availability_zone
#   engine = "aurora-mysql"
# }

# variable "checkday_rds_instance_availability_zone" {
#   type = string
#   description = "Checkday database instance availability zone"
#   default = "us-east-1a"
# }