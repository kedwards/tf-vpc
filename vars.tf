#
# required
#
variable "cidr" {
  description = "The IP address range of the VPC in CIDR notation."
  type        = string
}

variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
}

#
# optional
#
variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = false
}

variable "azs" {
  default     = []
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "create_database_internet_gateway_route" {
  description = "Controls if an internet gateway route for public database access should be created"
  type        = bool
  default     = false
}

variable "create_database_nat_gateway_route" {
  description = "Controls if a nat gateway route should be created to give internet access to the database subnets"
  type        = bool
  default     = false
}

variable "create_database_subnet_group" {
  default     = true
  description = "Controls if database subnet group should be created"
  type        = bool
}

variable "create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  type        = bool
  default     = false
}

variable "create_internet_gateway" {
  default     = true
  description = "A boolean flag to enable/disable the creation of an Internet Gateway"
  type        = bool
}

variable "create_vpc" {
  default     = true
  description = "Controls if VPC should be created."
  type        = bool
}

variable "database_route_table_tags" {
  description = "Additional tags for the database route tables"
  type        = map(string)
  default     = {}
}

variable "database_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "database_subnet_ipv6_prefixes" {
  default     = []
  description = "Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
}


variable "database_subnet_group_tags" {
  default     = {}
  description = "Additional tags for the database subnet group"
  type        = map(string)
}

variable "database_subnet_tags" {
  default     = {}
  description = "Additional tags for the database subnets"
  type        = map(string)
}

variable "database_subnets" {
  default     = []
  description = "A list of database subnets"
  type        = list(string)
}

variable "enable_dns_hostnames" {
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
}

variable "enable_dns_support" {
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
}

variable "enable_ipv6" {
  default     = false
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
}

variable "enable_nat_gateway" {
  default     = false
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
}

variable "external_nat_ip_ids" {
  default     = []
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
}

variable "igw_tags" {
  default     = {}
  description = "Additional tags for the internet gateway."
  type        = map(string)
}

variable "map_public_ip_on_launch" {
  default     = true
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
}

variable "nat_eip_tags" {
  default     = {}
  description = "Additional tags for the NAT EIP"
  type        = map(string)
}

variable "nat_gateway_tags" {
  default     = {}
  description = "Additional tags for the NAT gateways"
  type        = map(string)
}

variable "one_nat_gateway_per_az" {
  default     = false
  description = "Oone NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
}

variable "private_route_table_tags" {
  default     = {}
  description = "Additional tags for the private route tables."
  type        = map(string)
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  default     = null
  description = "Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
}

variable "private_subnet_ipv6_prefixes" {
  default     = []
  description = "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
}

variable "private_subnet_tags" {
  default     = {}
  description = "Additional tags for the private subnets"
  type        = map(string)
}

variable "private_subnets" {
  default     = []
  description = "A list of private subnets inside the VPC."
  type        = list(string)

}

variable "public_route_table_tags" {
  default     = {}
  description = "Additional tags for the public route tables."
  type        = map(string)
}


variable "public_subnet_assign_ipv6_address_on_creation" {
  default     = null
  description = "Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
}

variable "public_subnet_ipv6_prefixes" {
  default     = []
  description = "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
}

variable "public_subnet_tags" {
  default     = {}
  description = "A list of tags for the public subnets"
  type        = map(string)
}

variable "public_subnets" {
  default     = []
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "reuse_nat_ips" {
  default     = false
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
}

variable "single_nat_gateway" {
  default     = true
  description = "Provision a single shared NAT Gateway across all of your private networks"
  type        = bool
}

variable "subnets_az_state_filter" {
  default     = "available"
  description = "This value can be used to filter Availability Zones."
  type        = string
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "vpc_tags" {
  default     = {}
  description = "Additional tags for the VPC."
  type        = map(string)
}
