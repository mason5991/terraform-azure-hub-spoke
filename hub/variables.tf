variable "hub_name" {
  description = "Hub name"
  default = "hub"
}

variable "location" {
    description = "Location of the network"
    default     = "eastus"
}

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

variable "shared_key" {}

locals {
  hub_prefix = var.hub_name

  tags = {
    Terraform   = "true"
    Environment = var.hub_name
    Type        = "hub"
  }
}
