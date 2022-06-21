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

variable "hub_nva_rg_name" {

}

variable "hub_nva_rg_location" {
  default = "eastus"
}

variable "vm_username" {
  description = "Username for Virtual Machines"
  default     = "azureuser"
}

variable "vm_password" {
  description = "Password for Virtual Machines"
  default     = "azurevm123!"
}

variable "vm_size" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}

variable "address_prefix" {
  description = "Address prefix for hub gateway route table"
  default = "10.1.0.0/16"
}

variable "vnet_address_space" {
  description   = "Spoke virutal netwoork address space setting"
  default       = ["10.1.0.0/16"]
}

variable "mgmt_address_prefixes" {
  description   = "Spoke mgmt address prefixes"
  default       = ["10.1.0.64/27"]
}

variable "workload_address_prefixes" {
  description   = "Spoke workload address prefixes"
  default       = ["10.1.1.0/24"]
}

locals {
  tags = {
    Terraform   = "true"
    Environment = var.spoke_name
    Type        = "spoke"
  }
}
