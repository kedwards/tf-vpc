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