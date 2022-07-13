resource "azurerm_resource_group" "aks_rg" {
    name = "${var.cluster_name}-aks-rg"
    location = var.location

    tags = local.tags
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.name_prefix}-vnet"
    location            = azurerm_resource_group.aks_rg.location
    resource_group_name = azurerm_resource_group.aks_rg.name
    address_space       = var.vnet_address_space

    tags = local.tags
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-snet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "aks" {
  source = "../../modules/resources/aks"
  resource_group = azurerm_resource_group.aks_rg
  subnet = azurerm_subnet.subnet
  cluster_name = var.cluster_name
  subnet_address_prefixes = var.subnet_address_prefixes
  dns_prefix = var.dns_prefix
  agent_count = var.agent_count
  
  tags = local.tags
}
