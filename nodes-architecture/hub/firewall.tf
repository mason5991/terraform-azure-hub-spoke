resource "azurerm_subnet" "hub_firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.firewall_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

# Firewall public IP
resource "azurerm_public_ip" "hub_firewall_pip" {
  name                = "${local.hub_prefix}-firewall-pip"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  allocation_method   = "Static"
  sku = "Standard"

  tags = local.tags
}

# Hub firewall
resource "azurerm_firewall" "hub_firewall" {
  name                = "${local.hub_prefix}-firewall"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  ip_configuration {
    name                 = "${local.hub_prefix}-firewall-ip-conf"
    subnet_id            = azurerm_subnet.hub_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_firewall_pip.id
  }

  tags = local.tags
}

# Hub firewall network rules for DNS
resource "azurerm_firewall_network_rule_collection" "hub_firewall_nrc_dns" {
  name = "${local.hub_prefix}-firewall-nrc-dns"
  azure_firewall_name = azurerm_firewall.hub_firewall.name
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  priority = 100
  action = "Allow"

  rule {
    name = "DNS"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["53"]
    destination_addresses = ["8.8.8.8","8.8.4.4"]
    protocols = ["TCP","UDP"]
  }
}

# Hub firewall network rules for web access
resource "azurerm_firewall_network_rule_collection" "hub_firewall_nrc_web" {
  name = "${local.hub_prefix}-firewall-nrc-web"
  azure_firewall_name = azurerm_firewall.hub_firewall.name
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  priority = 101
  action = "Allow"
  rule {
    name = "HTTP"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["80", "8080"]
    destination_addresses = ["*"]
    protocols = ["TCP"]  
  }
  rule {
    name = "HTTPS"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["443"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
  rule {
    name = "Tendermint RPC"
    source_addresses = ["10.0.0.0/16"]
    destination_ports = ["26657"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "hub_firewall_diag" {
  name               = "${local.hub_prefix}-firewall-diag"
  target_resource_id = azurerm_firewall.hub_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_law.id
  depends_on = [azurerm_firewall.hub_firewall, azurerm_log_analytics_workspace.hub_law]

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
