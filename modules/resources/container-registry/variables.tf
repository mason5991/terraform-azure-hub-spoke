variable "resource_group" {
  description = "Resource group"
}

variable "sku" {
  default = "Premium"
}

variable "acr_name" {
  type = string
}

variable "admin_enabled" {
  type = bool
  default = false
}

variable "identity_ids" {
  type = list(string)
  default = []
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
