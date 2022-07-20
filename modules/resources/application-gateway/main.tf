locals {
  backend_address_pool_name      = "${var.name_prefix}-beap"
  frontend_port_name             = "${var.name_prefix}-feport"
  frontend_ip_configuration_name = "${var.name_prefix}-feip"
  http_setting_name              = "${var.name_prefix}-be-htst"
  listener_name                  = "${var.name_prefix}-httplstn"
  request_routing_rule_name      = "${var.name_prefix}-rqrt"
  redirect_configuration_name    = "${var.name_prefix}-rdrcfg"
}

// Application gateway subnet
resource "azurerm_subnet" "subnet" {
  count                = var.subnet_create == true ? 1 : 0
  name                 = "application-gateway-snet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

// Application gatway public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-ag-pip"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  
  allocation_method   = var.pip_allocation_method
  sku = var.pip_sku

  idle_timeout_in_minutes = var.pip_idle_timeout_in_minutes

  tags = local.tags
}

# Application gateway
resource "azurerm_application_gateway" "application_gateway" {
    name                = "${var.name_prefix}-ag"
    location            = var.resource_group.location
    resource_group_name = var.resource_group.name

    sku {
      name     = var.sku_name
      tier     = var.sku_tier
      capacity = var.sku_capacity
    }

    gateway_ip_configuration {
      name      = "${var.name_prefix}-ag-ip-conf"
      subnet_id = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    }

    waf_configuration {
      enabled = true
      firewall_mode = "Detection"
      rule_set_type = "OWASP"
      rule_set_version = "3.2"
    }

    frontend_port {
      name = local.frontend_port_name
      port = 80
    }
    
    frontend_ip_configuration {
      name                 = local.frontend_ip_configuration_name
      public_ip_address_id = azurerm_public_ip.pip.id
    }

    backend_address_pool {
      name = local.backend_address_pool_name
    }

    backend_http_settings {
      name                  = local.http_setting_name
      cookie_based_affinity = "Disabled"
      path                  = "/"
      protocol              = "Http"
      port                  = 80
      request_timeout       = 60
    }

    http_listener {
      name                           = local.listener_name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
    }

    request_routing_rule {
      name                       = local.request_routing_rule_name
      rule_type                  = "Basic"
      http_listener_name         = local.listener_name
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.http_setting_name
      priority                   = 100
    }

    depends_on = [azurerm_public_ip.pip]
    
    tags = local.tags
}


resource "azurerm_monitor_diagnostic_setting" "application_gateway_diag" {
  count              = var.application_gateway_monitoring == true ? 1 : 0
  name               = "${var.name_prefix}-ag-diag"
  target_resource_id = azurerm_application_gateway.application_gateway.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on = [azurerm_application_gateway.application_gateway, var.log_analytics_workspace_id]
  

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


resource "azurerm_monitor_diagnostic_setting" "application_gateway_pip_diag" {
  count                      = var.pip_monitoring == true ? 1 : 0
  name                       = "${var.name_prefix}-ag-pip-diag"
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
