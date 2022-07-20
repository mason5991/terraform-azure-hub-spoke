resource "azurerm_resource_group" "k8s_rg" {
    name = "${var.cluster_name}-k8s-rg"
    location = var.location

    tags = local.tags
}

# virtual network
resource "azurerm_virtual_network" "k8s_vnet" {
    name                = "${var.name_prefix}-vnet"
    location            = azurerm_resource_group.k8s_rg.location
    resource_group_name   = azurerm_resource_group.k8s_rg.name
    address_space       = var.vnet_address_space

    tags = local.tags
}

# Subnet
resource "azurerm_subnet" "k8s_subnet" {
  name                 = "${var.name_prefix}-snet"
  resource_group_name  = azurerm_resource_group.k8s_rg.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "dev_k8s" {
  source = "../../modules/resources/aks"
  resource_group = azurerm_resource_group.k8s_rg
  subnet = azurerm_subnet.k8s_subnet
  cluster_name = var.cluster_name
  subnet_address_prefixes = var.subnet_address_prefixes
  dns_prefix = var.dns_prefix
  agent_count = var.agent_count
  
  tags = local.tags
}

data "azurerm_container_registry" "main_container_registry" {
  name = var.main_acr_name
  resource_group_name = var.main_acr_resource_group_name
}

resource "azurerm_role_assignment" "dev_k8s_role_assignment" {
  principal_id                     = module.dev_k8s.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.main_container_registry.id
  skip_service_principal_aad_check = true
  depends_on = [module.dev_k8s]
}

####################################################
##       Settings for connection with hub         ##
####################################################

data "azurerm_virtual_network" "main_vnet" {
  name = var.main_hub.vnet.name
  resource_group_name = var.main_hub.resource_group.name
}

data "azurerm_resource_group" "main_resource_group" {
  name = var.main_hub.resource_group.name
}

// Network peering - spoke to hub
resource "azurerm_virtual_network_peering" "dev_k8s_to_main_peer" {
    name                      = "${data.azurerm_virtual_network.main_vnet.name}-peer"
    resource_group_name       = azurerm_resource_group.k8s_rg.name
    virtual_network_name      = azurerm_virtual_network.k8s_vnet.name
    remote_virtual_network_id = data.azurerm_virtual_network.main_vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [azurerm_virtual_network.k8s_vnet]
}

// Network peering - hub to spoke
resource "azurerm_virtual_network_peering" "main_to_dev_k8s_peer" {
    name                         = "${azurerm_virtual_network.k8s_vnet.name}-peer"
    resource_group_name          = data.azurerm_resource_group.main_resource_group.name
    virtual_network_name         = data.azurerm_virtual_network.main_vnet.name
    remote_virtual_network_id    = azurerm_virtual_network.k8s_vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
    depends_on = [azurerm_virtual_network.k8s_vnet]
}
