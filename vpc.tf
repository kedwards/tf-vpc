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