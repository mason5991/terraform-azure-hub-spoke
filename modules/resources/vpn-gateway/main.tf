// Vpn gateway subnet
resource "azurerm_subnet" "subnet" {
  count                = var.subnet_create == true ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = var.vnet_rg.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

// Vpn gatway public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-vg-pip"
  resource_group_name = var.vnet_rg.name
  location            = var.vnet_rg.location
  
  allocation_method   = var.pip_allocation_method
  sku = var.pip_sku

  idle_timeout_in_minutes = var.pip_idle_timeout_in_minutes

  tags = local.tags
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
    name                = "${var.name_prefix}-vg"
    location            = var.vnet_rg.location
    resource_group_name = var.vnet_rg.name

    type     = "Vpn"
    vpn_type = var.vpn_type

    active_active = var.active_active
    enable_bgp    = var.enable_bgp
    sku           = var.sku

    ip_configuration {
        name                          = "${var.name_prefix}-vg-ip-conf"
        public_ip_address_id          = azurerm_public_ip.pip.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    }

    depends_on = [azurerm_public_ip.pip]
    
    tags = local.tags
}


resource "azurerm_monitor_diagnostic_setting" "vpn_gateway_diag" {
  count              = var.vpn_gateway_monitoring == true ? 1 : 0
  name               = "${var.name_prefix}-vg-diag"
  target_resource_id = azurerm_virtual_network_gateway.vpn_gateway.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on = [azurerm_virtual_network_gateway.vpn_gateway, var.log_analytics_workspace_id]
  

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}


resource "azurerm_monitor_diagnostic_setting" "vpn_gateway_pip_diag" {
  count                      = var.pip_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-vg-pip-diag"
  target_resource_id         = azurerm_public_ip.pip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on                 = [azurerm_public_ip.pip, var.log_analytics_workspace_id]

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
    }
   
  }
  log {
    category = "DDoSMitigationFlowLogs"
    enabled = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "DDoSMitigationReports"
    enabled =true
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}
