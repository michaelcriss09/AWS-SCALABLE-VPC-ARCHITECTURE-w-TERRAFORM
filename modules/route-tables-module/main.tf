resource "aws_route_table" "route_tables" {
  vpc_id = var.rt_vpc

  tags = {
    Name = var.name
  }
  }

  resource "aws_route" "routes" {
  for_each = { for route in var.routes : route.destination_cidr_block => route }

  route_table_id         = aws_route_table.route_tables.id
  destination_cidr_block = each.value.destination_cidr_block

  transit_gateway_id = lookup(each.value, "transit_gateway_id", null)
  nat_gateway_id     = lookup(each.value, "nat_gateway_id", null)
  gateway_id         = lookup(each.value, "gateway_id", null)
}

resource "aws_route_table_association" "associations" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.route_tables.id
}

