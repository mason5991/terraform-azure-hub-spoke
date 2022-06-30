variable "hub_name" {
  description = "Hub name"
}

variable "hub_location" {
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

variable "mgmt_vm_username" {
    description = "Username for Virtual Machines"
    default     = "azureuser"
}

variable "mgmt_vm_size" {
    description = "Size of the VMs"
    default     = "Standard_D2s_v3"
}

variable "mgmt_vm_publisher" {
  default = "Canonical"
}

variable "mgmt_vm_offer" {
  default = "UbuntuServer"
}

variable "mgmt_vm_sku" {
  default = "18.04-LTS"
}

variable "mgmt_vm_version" {
  default = "latest"
}

variable "mgmt_vm_disk_name" {
  default = ""
}

variable "mgmt_vm_disk_caching" {
  default = "ReadWrite"
}

variable "mgmt_vm_create_option" {
  default = "FromImage"
}

variable "mgmt_vm_managed_disk_type" {
  default = "Standard_LRS"
}

variable "mgmt_vm_disk_size_gb" {
  default = 1024
}

variable "tags" {
  default = {}
}

locals {
  hub_prefix = var.hub_name

  tags = merge({
    Terraform   = "true"
    Name = var.hub_name
    Type        = "hub"
  }, var.tags)
}
