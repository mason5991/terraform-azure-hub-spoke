variable "resource_group" {
  description = "Resource group"
}

variable "sku" {
  default = "Premium"
}

variable "acr_name" {
  type = string
}

variable "name_prefix" {
  
}

variable "admin_enabled" {
  type = bool
  default = false
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
