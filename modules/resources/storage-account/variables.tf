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

variable "account_tier" {
  type = string
  default = "Standard"
}

variable "account_replication_type" {
  type = string
  default = "LRS"
}

variable "network_rules" {
  type = list(object({
    default_action = string
    /* ip_rules = optional(list(string)) */
    virtual_network_subnet_ids = list(string)
  }))
  default = []
}

variable "storage_share" {
  type = list(object({
    name_prefix = string
    quota       = number
  }))
  default = []
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
