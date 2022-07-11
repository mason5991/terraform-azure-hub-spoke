variable "vnet_rg" {
  description = "Virtual network resource group"
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
  description = "Need to create a subnet for bastion or not"
  type = bool
  default = false
}

variable "subnet" {}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "pip_allocation_method" {
  description = "Bastion public IP allocation method"
  default = "Static"
}

variable "pip_sku" {
  description = "Bastion public IP sku"
  default = "Standard"
}

variable "pip_idle_timeout_in_minutes" {
  default = 4
}

variable "name_prefix" {
  description = "Bastion name prefix"
  type = string
}

variable "sku" {
  default = "Standard"
}

variable "scale_units" {
  default = 10
}

variable "tunneling_enabled" {
  default = true
}

variable "bastion_monitoring" {
  default = false
}

variable "nsg_monitoring" {
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
