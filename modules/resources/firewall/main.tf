resource "azurerm_subnet" "subnet" {
  count                = var.subnet_create == true ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.vnet_rg.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

# Firewall public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-firewall-pip"
  location            = var.vnet_rg.location
  resource_group_name = var.vnet_rg.name

  allocation_method   = "Static"
  sku                 = var.pip_sku

  tags = local.tags
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.name_prefix}-nsg"
    resource_group_name  = var.vnet_rg.name
    location             = var.vnet_rg.location
  
    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }

    tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
    subnet_id                 = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }
}

# Firewall
resource "azurerm_firewall" "firewall" {
  name                = "${var.name_prefix}-firewall"
  location            = var.vnet_rg.location
  resource_group_name = var.vnet_rg.name

  sku_name = "AZFW_VNet"
  sku_tier = var.sku

  ip_configuration {
    name                 = "${var.name_prefix}-firewall-ip-conf"
    subnet_id            = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = local.tags
}

# Firewall network rules for DNS
resource "azurerm_firewall_network_rule_collection" "firewall_nrc_dns" {
  name = "${var.name_prefix}-firewall-nrc-dns"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.vnet_rg.name
  priority = 500
  action = "Allow"

  rule {
    name = "DNS"
    source_addresses = var.vnet_address_space
    destination_ports = ["53"]
    destination_addresses = ["8.8.8.8","8.8.4.4"]
    protocols = ["TCP","UDP"]
  }
}

# Firewall network rules for web access
resource "azurerm_firewall_network_rule_collection" "firewall_nrc" {
  name = "${var.name_prefix}-firewall-nrc"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.vnet_rg.name
  priority = 600
  action = "Allow"
  rule {
    name = "HTTP"
    source_addresses = var.vnet_address_space
    destination_ports = ["80", "8080"]
    destination_addresses = ["*"]
    protocols = ["TCP"]  
  }
  rule {
    name = "HTTPS"
    source_addresses = var.vnet_address_space
    destination_ports = ["443"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diag" {
  count              = var.firewall_monitoring == true ? 1 : 0
  name               = "${var.name_prefix}-firewall-diag"
  target_resource_id = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on = [azurerm_firewall.firewall, var.log_analytics_workspace_id]

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

resource "azurerm_monitor_diagnostic_setting" "firewall_nsg_diag" {
  count                      = var.nsg_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-firewall-nsg-diag"
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on                 = [azurerm_network_security_group.nsg, var.log_analytics_workspace_id]
  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled = true

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

resource "azurerm_monitor_diagnostic_setting" "firewall_pip_diag" {
  count                      = var.pip_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-firewall-pip-diag"
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
