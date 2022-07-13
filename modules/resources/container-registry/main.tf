resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  
  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  tags = local.tags
}
