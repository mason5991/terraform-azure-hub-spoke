variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "eastus"
}

variable "main_acr_name" {
  type = string
}

variable "dev_k8s_name" {
  type = string
}

variable "dev_k8s_resource_group_name" {
  type = string
}

locals {
  tags = {
    Terraform = true
    Type = "acr"
  }
}

