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
  vpc_id     = aws_vpc.checkday_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "checkday_private_subnet"
  }
}

resource "aws_subnet" "checkday_public_subnet" {
  vpc_id     = aws_vpc.checkday_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "checkday_public_subnet"
  }
}

variable "cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR Block for VPC"
}