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

variable "vnet_address_space" {
  type = list(string)
}

variable "name_prefix" {
  description = "Storage account name prefix"
}

variable "subnet_create" {
  type = bool
  default = false
}

variable "subnet" {

}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "sku" {
  type = string
  default = "Standard"
}

variable "pip_sku" {
  type = string
  default = "Standard"
}

variable "firewall_monitoring" {
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
