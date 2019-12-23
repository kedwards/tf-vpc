resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  count  = var.create_vpc && var.create_internet_gateway ? 1 : 0
  vpc_id = element(aws_vpc.this.*.id, 0)

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}