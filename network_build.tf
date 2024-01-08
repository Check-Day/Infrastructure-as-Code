resource "aws_vpc" "checkday_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "checkday_vpc"
  }
}

resource "aws_internet_gateway" "checkday_internet_gateway" {
  vpc_id = aws_vpc.checkday_vpc.id

  tags = {
    Name = "checkday_internet_gateway"
  }
}

resource "aws_subnet" "checkday_private_subnet" {
  for_each = {for az in var.availability_zones: az => index(var.availability_zones, az)}

  vpc_id            = aws_vpc.checkday_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.checkday_vpc.cidr_block, 8, each.value)
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "checkday_private_subnet_${each.key}"
  }
}

resource "aws_subnet" "checkday_public_subnet" {
  for_each = {for az in var.availability_zones: az => index(var.availability_zones, az) + length(var.availability_zones)}

  vpc_id            = aws_vpc.checkday_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.checkday_vpc.cidr_block, 8, each.value)
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "checkday_public_subnet_${each.key}"
  }
}

resource "aws_route_table" "checkday_public_routetable" {
  vpc_id = aws_vpc.checkday_vpc.id
  tags = {
    Name = "checkday_public_routetable"
  }
}

resource "aws_route_table_association" "checkday_public_routetable_association" {
  for_each   = aws_subnet.checkday_public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.checkday_public_routetable.id
}

resource "aws_route_table" "checkday_private_routetable" {
  vpc_id = aws_vpc.checkday_vpc.id
  tags = {
    Name = "checkday_private_routetable"
  }
}

resource "aws_route_table_association" "checkday_private_routetable_association" {
  for_each   = aws_subnet.checkday_private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.checkday_private_routetable.id
}

resource "aws_lb" "checkday_load_balancer" {
  name               = "checkday-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.checkday_load_balancer_security_group.id]
  subnets            = [for subnet in aws_subnet.checkday_public_subnet : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "checkday_load_balancer_target_group" {
  name     = "checkday-load-balancer-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.checkday_vpc.id
}

resource "aws_lb_listener" "checkday_load_balancer_target_group_listener" {
  load_balancer_arn = aws_lb.checkday_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.checkday_load_balancer_target_group.arn
  }
}

resource "aws_db_subnet_group" "checkday_db_subnet_group" {
  name       = "checkday_db_subnet_group"
  subnet_ids = [for subnet in aws_subnet.checkday_private_subnet : subnet.id]

  tags = {
    Name = "checkday_db_subnet_group"
  }
}

resource "aws_rds_cluster" "checkday_database" {
  cluster_identifier      = "checkday-aurora-db"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.0"
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.database_username
  master_password         = var.database_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  final_snapshot_identifier = "checkday-db-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
}

locals {
  host = aws_rds_cluster.checkday_database.endpoint
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

variable "cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR Block for VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "environment" {
  type        = string
  description = "Describes environment"
  default     = "dev"
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