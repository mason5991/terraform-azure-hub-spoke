// Bastion subnet
resource "azurerm_subnet" "hub_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.bastion_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

// Bastion public IP
resource "azurerm_public_ip" "hub_bastion_pip" {
  name                = "${local.hub_prefix}-bastion-pip"
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  location            = azurerm_resource_group.hub_vnet_rg.location
  
  allocation_method   = "Static"
  sku = "Standard"

  tags = local.tags
}

resource "azurerm_network_security_group" "hub_bastion_nsg" {
  name = "${local.hub_prefix}-bastion-nsg"
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  location = azurerm_resource_group.hub_vnet_rg.location
  security_rule {
    name                       = "Allow_TCP_443_Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_TCP_443_GatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_TCP_4443_GatewayManager"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 4443
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_TCP_443_AzureLoadBalancer"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Deny_any_other_traffic"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_TCP_3389_VirtualNetwork"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "Allow_TCP_22_VirtualNetwork"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "Allow_TCP_443_AzureCloud"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = local.tags
}

// Bastion host
resource "azurerm_bastion_host" "hub_bastion_host" {
  name                = "${local.hub_prefix}-bastion-host"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  ip_configuration {
    name                 = "${local.hub_prefix}-bastion-host-ip-conf"
    subnet_id            = azurerm_subnet.hub_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_bastion_pip.id
  }

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "hub_bastion_diag" {
  name               = "${local.hub_prefix}-bastion-diag"
  target_resource_id = azurerm_bastion_host.hub_bastion_host.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_law.id
  depends_on = [azurerm_bastion_host.hub_bastion_host, azurerm_log_analytics_workspace.hub_law]
  

  log {
    category = "BastionAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
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

resource "azurerm_monitor_diagnostic_setting" "hub_bastion_nsg_diag" {
  name = "${local.hub_prefix}-bastion-nsg-diag"
  target_resource_id = azurerm_network_security_group.hub_bastion_nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_law.id
  depends_on = [azurerm_network_security_group.hub_bastion_nsg, azurerm_log_analytics_workspace.hub_law]
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
      enabled =true
    }
  }

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

resource "azurerm_monitor_diagnostic_setting" "hub_bastion_pip_diag" {
  name = "${local.hub_prefix}-bastion-pip-diag"
  target_resource_id = azurerm_public_ip.hub_bastion_pip.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_law.id
  depends_on = [azurerm_public_ip.hub_bastion_pip, azurerm_log_analytics_workspace.hub_law]

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
