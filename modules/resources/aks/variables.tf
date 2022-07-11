variable "cluster_name" {

}

variable "location" {
  default = "eastus"
}

variable "vnet_rg" {}

variable "dns_prefix" {
  description = "DNS prefix, like prod/test/dev"
}

variable "subnet" {}

variable "admin_username" {
  default = "auzreuser"
}

variable "agent_conut" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D2_v2"
}

variable "os_disk_size_gb" {
  default = 128
}

variable "tags" {}

locals {
  tags = merge({}, var.tags)
}
