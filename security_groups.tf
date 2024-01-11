resource "aws_security_group" "checkday_load_balancer_security_group" {
  name        = "checkday_load_balancer_security_group"
  description = "Load Balancer Trafic Management"
  vpc_id      = aws_vpc.checkday_vpc.id

  ingress {
    description      = "Site Traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Secured Site Traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "checkday_load_balancer_security_group"
  }
}

resource "aws_security_group" "checkday_db_security_group" {
  name        = "checkday_db_security_group"
  description = "Database Traffic Management"
  vpc_id      = aws_vpc.checkday_vpc.id

  ingress {
    description      = "DB Traffic"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.checkday_app_security_group.id]
  }

  tags = {
    Name = "checkday_db_security_group"
  }
}

resource "aws_security_group" "checkday_app_security_group" {
  name        = "checkday_app_security_group"
  description = "App Traffic Management"
  vpc_id      = aws_vpc.checkday_vpc.id

  dynamic "ingress" {
    for_each = var.appPorts

    content {
      description      = "App Traffic"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      security_groups  = [aws_security_group.checkday_load_balancer_security_group.id]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "checkday_app_security_group"
  }
}

variable "appPorts" {
  type        = list(number)
  description = "Describes app port"
  default     = [22, 5969]
}