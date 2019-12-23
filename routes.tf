#
# route_table::public
#
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-public-rt", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

#
# route::internet gateway
#
resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  route_table_id         = aws_route_table.public[0].id

  timeouts {
    create = "5m"
  }
}

#
# route table assoc::public
#
resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  route_table_id = aws_route_table.public[0].id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

#
# route_table::private
#
resource "aws_route_table" "private" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-private-rt" : format(
        "%s-private-route-table-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.private_route_table_tags,
  )
}

#
# route::nat gateway
#
resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
  route_table_id         = element(aws_route_table.private.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

#
# route table assoc::private
#
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.private.*.id, count.index)
}

#
# route_table::database
#
resource "aws_route_table" "database" {
  count = var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    var.database_route_table_tags,
    {
      "Name" = "${var.name}-db-subnet"
    },
  )
}

#
# route::database internet gateway
#
resource "aws_route" "database_internet_gateway" {
  count = var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 && var.create_database_internet_gateway_route && false == var.create_database_nat_gateway_route ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  route_table_id         = aws_route_table.database[0].id

  timeouts {
    create = "5m"
  }
}

#
# route::database nat gateway
#
resource "aws_route" "database_nat_gateway" {
  count                  = var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 && false == var.create_database_internet_gateway_route && var.create_database_nat_gateway_route && var.enable_nat_gateway ? local.nat_gateway_count : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  timeouts {
    create = "5m"
  }
}

#
# route table assoc::database
#
resource "aws_route_table_association" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  route_table_id = element(
    coalescelist(aws_route_table.database.*.id, aws_route_table.private.*.id),
    var.single_nat_gateway || var.create_database_subnet_route_table ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.database.*.id, count.index)
}
