resource "aws_route" "checkday_public_route_in_public_route_table" {
  route_table_id         = aws_route_table.checkday_public_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.checkday_internet_gateway.id
}

