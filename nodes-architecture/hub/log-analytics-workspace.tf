resource "azurerm_log_analytics_workspace" "hub_law" {
  name = "${local.hub_prefix}-law"
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  location = azurerm_resource_group.hub_vnet_rg.location

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }

  tags = local.tags
}
