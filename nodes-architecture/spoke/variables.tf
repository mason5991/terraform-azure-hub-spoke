variable "location" {
  description = "Location of the network"
  default     = "eastus"
}

variable "spoke_name" {
  description = "Spoke name"
}

variable "hub_name" {
  description = "Hub name"
}

variable "hub_vnet_id" {
  description = "Hub virtual network id"
}

variable "hub_vnet_name" {
  description = "Hub virtual network name"
}

variable "hub_vnet_rg_name" {
  description = "Hub virtual network resource group name"
}

variable "vm_username" {
  description = "Username for Virtual Machines"
  default     = "azureuser"
}

variable "vm_size" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}

variable "vnet_address_space" {
  description   = "Spoke virutal netwoork address space setting"
}

variable "address_prefixes" {
  description = "Address prefixes"
}

locals {
  tags = {
    Terraform   = "true"
    Environment = var.spoke_name
    Type        = "spoke"
  }
}
