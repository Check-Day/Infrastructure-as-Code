resource "aws_security_group" "checkday_db_security_group" {
  name        = "checkday_db_security_group"
  description = "Database Traffic Management"
  vpc_id      = aws_vpc.checkday_vpc.id

  ingress {
    description      = "DB Traffic"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.checkday_eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "checkday_db_security_group"
  }
}

resource "aws_db_subnet_group" "checkday_db_subnet_group" {
  name       = "checkday_db_subnet_group"
  subnet_ids = concat([for subnet in aws_subnet.checkday_private_subnet : subnet.id])

  tags = {
    Name = "checkday_db_subnet_group"
  }
}