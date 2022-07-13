variable "cluster_name" {
  type = string
}

variable "location" {
  default = "eastus"
}

variable "resource_group" {}

variable "dns_prefix" {
  description = "DNS prefix, like prod/test/dev"
}

variable "subnet" {}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "admin_username" {
  default = "auzreuser"
}

variable "agent_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D2_v2"
}

variable "os_disk_size_gb" {
  default = 128
}

variable "sku_tier" {
  default = "Free"
}

variable "load_balancer_sku" {
  default = "standard"
}

variable "public_network_access_enabled" {
  default = false
}

variable "default_node_pool_name" {
  default = "agentpool"
}

variable "role_based_access_control_enabled" {
  type = bool
  default = true
}

variable "tags" {}

locals {
  tags = merge({}, var.tags)
}
