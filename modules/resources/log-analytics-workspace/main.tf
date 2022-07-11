resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-law"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

  tags = local.tags
}
