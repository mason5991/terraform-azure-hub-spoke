variable "resource_group" {
  description = "Resource group"
  type = object({
    name    = string
    location = string
  })
}

variable "vnet" {
  description = "Virtual network"
  type = object({
    name    = string
  })
}

variable "subnet_create" {
  description = "Need to create a subnet for vpn gateway or not"
  type = bool
  default = false
}

variable "subnet" {}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "pip_allocation_method" {
  description = "Vpn gateway public IP allocation method"
  default = "Dynamic"
}

variable "pip_sku" {
  description = "Vpn gateway public IP sku"
  default = "Standard"
}

variable "pip_idle_timeout_in_minutes" {
  description = "Vpn gateway public IP timeout"
  default = 4
}

variable "name_prefix" {
  description = "Vpn gateway name prefix"
  type = string
}

variable "vpn_type" {
  default = "RouteBased"
}

variable "sku" {
  default = "VpnGw1"
}

variable "active_active" {
  type = bool
  default = false
}

variable "enable_bgp" {
  type = bool
  default = false
}

variable "vpn_gateway_monitoring" {
  default = false
}

variable "pip_monitoring" {
  default = false
}

variable "log_analytics_workspace_id" {
  default = ""
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
