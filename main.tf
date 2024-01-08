data "aws_region" "current" {}

resource "aws_vpc_ipam" "checkday" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "checkday" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.checkday.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "checkday" {
  ipam_pool_id = aws_vpc_ipam_pool.checkday.id
  cidr         = "195.52.0.0/16"
}

resource "aws_vpc" "checkday" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.checkday.id
  enable_dns_support = true
  enable_dns_hostnames = true
  ipv4_netmask_length = 28
  depends_on = [
    aws_vpc_ipam_pool_cidr.checkday
  ]
  tags = {
    Name = "checkday_dev"
  }
}