variable "vnet_rg" {}

variable "vnet" {}

variable "name_prefix" {
  type = string
}

variable "subnet_create" {
  type    = bool
  default = false
}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  type    = bool
  default = false
}

variable "subnet_private_ip_address_allocation" {
  default = "Dynamic"
}

variable "subnet" {}

variable "pip_create" {
  type    = bool
  default = false
}

variable "pip_allocation_method" {
  default = "Static"
}

variable "pip_sku" {
  default = "Standard"
}

variable "nic_enable_ip_forwarding" {
  type    = bool
  default = false
}

variable "vm_name" {
  type = string
}

variable "vm_username" {
  description = "Username for Virtual Machines"
  default     = "azureuser"
}

variable "vm_size" {
  description = "Size of the VMs"
  default     = "Standard_D2s_v3"
}

variable "vm_publisher" {
  default = "Canonical"
}

variable "vm_offer" {
  default = "UbuntuServer"
}

variable "vm_sku" {
  default = "18.04-LTS"
}

variable "vm_version" {
  default = "latest"
}

variable "vm_disk_name" {
  default = ""
}

variable "vm_disk_caching" {
  default = "ReadWrite"
}

variable "vm_create_option" {
  default = "FromImage"
}

variable "vm_managed_disk_type" {
  default = "Standard_LRS"
}

variable "vm_disk_size_gb" {
  default = 1024
}

variable "tags" {
  default = {}
}

locals {
  tags = merge({}, var.tags)
}
