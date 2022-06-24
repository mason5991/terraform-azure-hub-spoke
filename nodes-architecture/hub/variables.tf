variable "hub_name" {
  description = "Hub name"
}

variable "location" {
    description = "Location of the network"
    default     = "eastus"
}

variable "vnet_address_space" {
  type = list(string)
}

variable "gateway_subnet_address_prefixes" {
  type = list(string)
}

variable "firewall_subnet_address_prefixes" {
  type = list(string)
}

variable "bastion_subnet_address_prefixes" {
  type = list(string)
}

variable "mgmt_subnet_address_prefixes" {
  type = list(string)
}

variable "shared_key" {}

variable "vm_username" {
    description = "Username for Virtual Machines"
    default     = "azureuser"
}

variable "vm_password" {
    description = "Password for Virtual Machines"
    default = "azurevm123!"
}

variable "vm_size" {
    description = "Size of the VMs"
    default     = "Standard_DS1_v2"
}

locals {
  hub_prefix = var.hub_name

  tags = {
    Terraform   = "true"
    Environment = var.hub_name
    Type        = "hub"
  }
}
