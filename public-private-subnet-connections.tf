resource "aws_route_table" "checkday_public_routetable" {
  vpc_id = aws_vpc.checkday_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.checkday_internet_gateway.id
  }

  tags = {
    Name = "checkday_public_routetable"
  }
}

resource "aws_route_table_association" "checkday_public_routetable_association" {
  for_each   = aws_subnet.checkday_public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.checkday_public_routetable.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.checkday_public_subnet

  vpc = true
  tags = {
    Name = "NAT-EIP-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.checkday_public_subnet

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "NAT-Gateway-${each.key}"
  }
}

resource "aws_route_table" "checkday_nat_private_routetable" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.checkday_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "Checkday-NAT-Private-RouteTable-${each.key}"
  }
}

resource "aws_route_table_association" "checkday_private_routetable_association" {
  for_each   = aws_subnet.checkday_private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.checkday_nat_private_routetable[each.key].id
}