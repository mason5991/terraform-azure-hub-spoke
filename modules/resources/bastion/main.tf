// Bastion subnet
resource "azurerm_subnet" "subnet" {
  count                = var.subnet_create == true ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

// Bastion public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-bt-pip"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  
  allocation_method   = var.pip_allocation_method
  sku = var.pip_sku

  idle_timeout_in_minutes = var.pip_idle_timeout_in_minutes

  tags = local.tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-bt-nsg"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
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

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
    subnet_id                 = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }
}

// Bastion host
resource "azurerm_bastion_host" "bastion" {
  name                = "${var.name_prefix}-bt"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku = var.sku
  scale_units = var.scale_units
  tunneling_enabled = var.tunneling_enabled

  ip_configuration {
    name                 = "${var.name_prefix}-bt-ip-conf"
    subnet_id            = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "bastion_diag" {
  count              = var.bastion_monitoring == true ? 1 : 0
  name               = "${var.name_prefix}-bt-diag"
  target_resource_id = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on = [azurerm_bastion_host.bastion, var.log_analytics_workspace_id]
  

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

resource "azurerm_monitor_diagnostic_setting" "bastion_nsg_diag" {
  count                      = var.nsg_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-bt-nsg-diag"
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

resource "azurerm_monitor_diagnostic_setting" "bastion_pip_diag" {
  count                      = var.pip_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-bt-pip-diag"
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
