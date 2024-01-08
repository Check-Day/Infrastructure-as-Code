resource "aws_subnet" "checkday_public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.checkday.id
  cidr_block              = cidrsubnet(var.publicCidr, 8, count.index + 4)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "checkday_public_${count.index}"
  }
}

resource "aws_subnet" "checkday_private_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.checkday.id
  cidr_block              = cidrsubnet(var.privateCidr, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "checkday_private_${count.index}"
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "privateCidr" {
  type        = string
  default     = "10.1.0.0/20"
  description = "CIDR Block for VPC Private Subnets"
}

variable "publicCidr" {
  type        = string
  default     = "10.1.64.0/20"
  description = "CIDR Block for VPC Public Subnets"
}
