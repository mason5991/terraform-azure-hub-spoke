resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  
  identity {
    type = "UserAssigned"
    identity_ids = concat([azurerm_user_assigned_identity.registry_uai.id], var.identity_ids)
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  tags = local.tags
}

resource "azurerm_user_assigned_identity" "registry_uai" {
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  name = "${var.acr_name}-registry-uai"

  tags = local.tags
}
