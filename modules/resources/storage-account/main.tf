resource "azurerm_subnet" "storage_account_subnet" {
  count                = var.subnet_create == true ? 1 : 0
  name                 = "${var.name_prefix}-sg-snet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet_address_prefixes
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.name_prefix}storageaccount"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  dynamic "network_rules" {
    for_each = var.network_rules

    content {
      default_action = network_rules.value.default_action
      /* ip_rules = length(network_rules.value.ip_rules) > 0 ? network_rules.value.ip_rules : [] */
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
  
  tags = local.tags
}

resource "azurerm_storage_share" "storage_share" {
  count = length(var.storage_share)
  name = "${var.storage_share[count.index].name_prefix}-share"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota = var.storage_share[count.index].quota
  depends_on = [azurerm_storage_account.storage_account]
  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}
