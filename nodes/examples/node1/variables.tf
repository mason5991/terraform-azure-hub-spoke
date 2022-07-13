variable "spoke_location" {
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
  default     = "Standard_D2s_v3"
}

variable "vm_publisher" {
  default = "Canonical"
}

variable "vm_offer" {
  default = "UbuntuServer"
}

variable "vm_sku" {
  default = "20.04-LTS"
}

variable "vm_version" {
  default = "latest"
}

variable "vnet_address_space" {
  description = "Spoke virutal network address space setting"
}

variable "workload_address_prefixes" {
  description = "Workload address prefixes"
}

variable "tags" {
  default = {}
}
