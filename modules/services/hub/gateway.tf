resource "azurerm_subnet" "hub_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.gateway_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "hub_vpn_gateway_pip" {
    name                = "${local.hub_prefix}-vpn-gateway-pip"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name

    // VPN gateway must have PublicIPAllocationMethod as Dynamic
    allocation_method = "Dynamic"
    
    tags = local.tags
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "hub_vpn_gateway" {
    name                = "${local.hub_prefix}-vpn-gateway"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
        name                          = "${local.hub_prefix}-vpn-gateway-ip-conf"
        public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = azurerm_subnet.hub_gateway_subnet.id
    }

    depends_on = [azurerm_public_ip.hub_vpn_gateway_pip]
    
    tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "hub_vpn_gateway_diag" {
  name               = "${local.hub_prefix}-vpn-gateway-diag"
  target_resource_id = azurerm_virtual_network_gateway.hub_vpn_gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_law.id
  depends_on = [azurerm_virtual_network_gateway.hub_vpn_gateway, azurerm_log_analytics_workspace.hub_law]

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
