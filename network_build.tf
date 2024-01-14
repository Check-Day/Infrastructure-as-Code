resource "aws_vpc" "checkday_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support = true
  enable_dns_hostnames = true

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
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/checkday_eks_cluster" = "owned"
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
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/checkday_eks_cluster" = "owned"
  }
}

resource "aws_lb" "checkday_load_balancer" {
  name               = "checkday-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.checkday_load_balancer_security_group.id]
  subnets            = [for subnet in aws_subnet.checkday_public_subnet : subnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "checkday_load_balancer_target_group" {
  name     = "checkday-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.checkday_vpc.id
}

resource "aws_lb_listener" "checkday_load_balancer_target_group_listener" {
  load_balancer_arn = aws_lb.checkday_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.checkday_load_balancer_target_group.arn
  }
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

variable "certificate_arn" {
  type = string
  description = "contains certificate arn from aws certifiate manager"
  default = "arn:aws:acm:us-east-1:467465390813:certificate/4a3b1c6c-ba61-41fc-9e66-bd4697b7d41b"
}