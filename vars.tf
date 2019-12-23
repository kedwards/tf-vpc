variable "create_vpc" {
  description = "Controls if VPC should be created.  Defaults true."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
}

variable "cidr" {
  description = "The IP address range of the VPC in CIDR notation."
  type        = string
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. Defaults false."
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "create_internet_gateway" {
  description = "A boolean flag to enable/disable the creation of an Internet Gateway.  Defaults true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for the VPC."
  type        = map(string)
  default     = {}
}