variable "location" {
  default = "eastus"
}

variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_address_prefixes" {
  type = list(string)
}

variable "dns_prefix" {
  type = string
}

variable "agent_count" {
  type = number
}

variable "main_hub" {
  type = object({
    vnet = object({
      name = string
    })
    resource_group = object({
      name = string
    })
  })
}

variable "main_acr_name" {

}

variable "main_acr_resource_group_name" {

}

variable "tags" {
  default = {}
}

locals {
  tags = merge({
    Terraform   = true
    Name        = var.cluster_name
    Type        = "hub"
    Category    = "k8s"
  }, var.tags)
}
