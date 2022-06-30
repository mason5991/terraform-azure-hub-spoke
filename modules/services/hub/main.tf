locals {
    hub_location       = var.hub_location
    hub_vnet_rg        = "${var.hub_name}-vnet-rg"
}

resource "azurerm_resource_group" "hub_vnet_rg" {
    name     = local.hub_vnet_rg
    location = local.hub_location

    tags = local.tags
}

# Hub virtual network
resource "azurerm_virtual_network" "hub_vnet" {
    name                = "${local.hub_prefix}-vnet"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name
    address_space       = var.vnet_address_space

    tags = local.tags
}

