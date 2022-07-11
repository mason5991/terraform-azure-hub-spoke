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
  description = "Name prefix"
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
