#
# locals
#
locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets)
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  #
  # Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
  # Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
  #
  # The logical expression would be: nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
  # but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
  #
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

#
# vpc 
#
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  assign_generated_ipv6_cidr_block = var.enable_ipv6
  cidr_block                       = var.cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s-vpc", var.name)
    },
    var.tags,
    var.vpc_tags
  )
}

#
# Internet Gateway
#
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-igw", var.name)
    },
    var.tags,
    var.igw_tags,
  )
}

#
# Public subnet
#
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  vpc_id                          = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format(
        "%s-public-subnet-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#
# Private subnet
#
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = var.private_subnets[count.index]
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null
  vpc_id                          = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format(
        "%s-private-subnet-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

#
# eip::nat gateway
#
resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-eip-nat-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
}

#
# nat gateway
#
resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )

  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-nat-gw-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

#
# Database subnet
#
resource "aws_subnet" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  assign_ipv6_address_on_creation = var.database_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.database_subnet_assign_ipv6_address_on_creation
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = var.database_subnets[count.index]
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.database_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.database_subnet_ipv6_prefixes[count.index]) : null
  vpc_id                          = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format(
        "%s-db-subnet-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.database_subnet_tags,
  )
}

resource "aws_db_subnet_group" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0

  name        = lower(var.name)
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database.*.id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.database_subnet_group_tags,
  )
}

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
