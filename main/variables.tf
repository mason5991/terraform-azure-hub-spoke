variable "location" {
  default = "eastus"
}

variable "hub_name" {}

variable "spoke_name" {}

variable "hub_vnet_address_space" {
  type = list(string)
}

variable "spoke_vnet_address_space" {
  type = list(string)
}

# Bastion
variable "bastion_subnet_create" {
  type = bool
  default = false
}

variable "bastion_subnet_address_prefixes" {
  type = list(string)
}

variable "bastion_monitoring" {
  type = bool
  default = false
}

variable "bastion_nsg_monitoring" {
  type = bool
  default = false
}

variable "bastion_pip_monitoring" {
  type = bool
  default = false
}

# Mgmt
variable "hub_mgmt_subnet_create" {
  type = bool
  default = false
}

variable "hub_mgmt_subnet_address_prefixes" {
  type = list(string)
}

variable "hub_mgmt_vm_name" {
  type = string
}

# Firewall
variable "firewall_subnet_create" {
  type = bool
  default = false
}

variable "firewall_subnet_address_prefixes" {
  type = list(string)
}

variable "firewall_monitoring" {
  type = bool
  default = false
}

variable "firewall_pip_monitoring" {
  type = bool
  default = false
}

# Vpn gateway
variable "vpn_gateway_subnet_create" {
  type = bool
  default = false
}

variable "vpn_gateway_subnet_address_prefixes" {
  type = list(string)
}

variable "vpn_gateway_monitoring" {
  type = bool
  default = false
}

variable "vpn_gateway_pip_monitoring" {
  type = bool
  default = false
}


# Storage account
variable "storage_account_subnet_create" {
  type = bool
  default = false
}

variable "storage_account_subnet_address_prefixes" {
  type = list(string)
}

variable "storage_share" {
  type = list(object({
    name_prefix = string
    quota       = number
  }))
  default = []
}

# internal mntr
variable "mntr_internal_subnet_create" {
  type = bool
  default = false
}

variable "mntr_internal_subnet_address_prefixes" {
  type = list(string)
}

variable "mntr_internal_vm_name" {
  type = string
}

# external mntr
variable "mntr_external_subnet_create" {
  type = bool
  default = false
}

variable "mntr_external_subnet_address_prefixes" {
  type = list(string)
}

variable "mntr_external_vm_name" {
  type = string
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

variable "vm_create_option" {
  default = "FromImage"
}

variable "vm_managed_disk_type" {
  default = "StandardSSD_LRS"
}

variable "vm_disk_size_gb" {
  default = 1024
}

variable "tags" {
  default = {}
}

locals {
  location = var.location
}
