locals {
  host = aws_rds_cluster_endpoint.checkday_database_cluster_instance_endpoint.endpoint
  database_username = var.database_username
  database_password = var.database_password
  database_name = var.database_name
  database_dialect = var.database_dialect
}

resource "aws_ssm_parameter" "DATABASE_HOST" {
  name  = "DATABASE_HOST"
  type  = "SecureString"
  value = local.host
  overwrite = true
}

resource "aws_ssm_parameter" "DATABASE_USERNAME" {
  name  = "DATABASE_USERNAME"
  type  = "SecureString"
  value = local.database_username
  overwrite = true
}

resource "aws_ssm_parameter" "DATABASE_PASSWORD" {
  name  = "DATABASE_PASSWORD"
  type  = "SecureString"
  value = local.database_password
  overwrite = true
}

resource "aws_ssm_parameter" "DATABASE_NAME" {
  name  = "DATABASE_NAME"
  type  = "SecureString"
  value = local.database_name
  overwrite = true
}

resource "aws_ssm_parameter" "DATABASE_DIALECT" {
  name  = "DATABASE_DIALECT"
  type  = "SecureString"
  value = local.database_dialect
  overwrite = true
}

variable "database_username" {
  type        = string
  description = "Database Username"
  default     = "root"
}

variable "database_password" {
  type        = string
  description = "Database Password"
  default     = "rootroot"
}

variable "database_name" {
  type        = string
  description = "Database Name"
  default     = "checkdayclient"
}

variable "database_dialect" {
  type        = string
  description = "Database Dialect"
  default     = "mysql"
}