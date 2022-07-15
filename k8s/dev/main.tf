/* data "azurerm_user_assigned_identity" "registry_uai" {
  name = var.registry_uai_name
  resource_group_name = var.registry_uai_resource_group_name
} */


resource "azurerm_resource_group" "k8s_rg" {
    name = "${var.cluster_name}-k8s-rg"
    location = var.location

    tags = local.tags
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.name_prefix}-vnet"
    location            = azurerm_resource_group.k8s_rg.location
    resource_group_name   = azurerm_resource_group.k8s_rg.name
    address_space       = var.vnet_address_space

    tags = local.tags
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-snet"
  resource_group_name  = azurerm_resource_group.k8s_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
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
  subnet = azurerm_subnet.subnet
  cluster_name = var.cluster_name
  subnet_address_prefixes = var.subnet_address_prefixes
  dns_prefix = var.dns_prefix
  agent_count = var.agent_count
  /* kubelet_identity = {
    client_id = data.azurerm_user_assigned_identity.registry_uai.client_id
    object_id = data.azurerm_user_assigned_identity.registry_uai.principal_id
    user_assigned_identity_id = data.azurerm_user_assigned_identity.registry_uai.id
  } */
  
  tags = local.tags
}

/* resource "azurerm_role_assignment" "aks_acr_role_assignment" {
  principal_id                     = module.aks.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
} */
