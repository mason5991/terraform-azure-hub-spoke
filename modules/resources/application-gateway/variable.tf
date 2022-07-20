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
  description = "Need to create a subnet for application gateway or not"
  type = bool
  default = false
}

variable "subnet" {}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "pip_allocation_method" {
  description = "Application gateway public IP allocation method"
  default = "Static"
}

variable "pip_sku" {
  description = "Application gateway public IP sku"
  default = "Standard"
}

variable "pip_idle_timeout_in_minutes" {
  description = "Application gateway public IP timeout"
  default = 4
}

variable "name_prefix" {
  description = "Application gateway name prefix"
  type = string
}

variable "sku_name" {
  type = string
  default = "WAF_v2"
}

variable "sku_tier" {
  type = string
  default = "WAF_v2"
}

variable "sku_capacity" {
  default = 2
}

variable "application_gateway_monitoring" {
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
