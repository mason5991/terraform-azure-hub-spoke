terraform {

  required_version = ">=0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
    }
    resource_group {
       prevent_deletion_if_contains_resources = false
    }
  }
}
