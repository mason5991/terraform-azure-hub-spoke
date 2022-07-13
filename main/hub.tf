locals {
    hub_rg               = "${var.hub_name}-rg"
    hub_prefix           = var.hub_name 
    hub_tags = merge({
      Terraform   = true
      Name        = var.hub_name
      Type        = "hub"
    }, var.tags)
}


resource "azurerm_resource_group" "hub_rg" {
    name     = local.hub_rg
    location = local.location

    tags = local.hub_tags
}

# Hub virtual network
resource "azurerm_virtual_network" "hub_vnet" {
    name                = "${local.hub_prefix}-vnet"
    location            = azurerm_resource_group.hub_rg.location
    resource_group_name = azurerm_resource_group.hub_rg.name
    address_space       = var.hub_vnet_address_space

    tags = local.hub_tags
}

# Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.bastion_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "bastion" {
  source = "../modules/resources/bastion"
  resource_group = azurerm_resource_group.hub_rg
  vnet = azurerm_virtual_network.hub_vnet
  name_prefix = local.hub_prefix
  subnet_create = var.bastion_subnet_create
  subnet = azurerm_subnet.bastion_subnet
  subnet_address_prefixes = var.bastion_subnet_address_prefixes
  bastion_monitoring = var.bastion_monitoring
  nsg_monitoring = var.bastion_nsg_monitoring
  pip_monitoring = var.bastion_pip_monitoring
  log_analytics_workspace_id = module.log_analytics_workspace.law.id

  tags = local.hub_tags
}

# Firewall
resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.firewall_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "firewall" {
  source = "../modules/resources/firewall"
  resource_group = azurerm_resource_group.hub_rg
  vnet = azurerm_virtual_network.hub_vnet
  vnet_address_space = var.hub_vnet_address_space
  name_prefix = local.hub_prefix
  subnet_create = var.bastion_subnet_create
  subnet = azurerm_subnet.firewall_subnet
  subnet_address_prefixes = var.firewall_subnet_address_prefixes
  firewall_monitoring = var.firewall_monitoring
  pip_monitoring = var.firewall_pip_monitoring
  log_analytics_workspace_id = module.log_analytics_workspace.law.id

  tags = local.hub_tags
}

# Vpn gateway
resource "azurerm_subnet" "vpn_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.vpn_gateway_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "vpn_gateway" {
  source = "../modules/resources/vpn-gateway"
  resource_group = azurerm_resource_group.hub_rg
  vnet = azurerm_virtual_network.hub_vnet
  name_prefix = local.hub_prefix
  subnet_create = var.vpn_gateway_subnet_create
  subnet = azurerm_subnet.vpn_gateway_subnet
  subnet_address_prefixes = var.vpn_gateway_subnet_address_prefixes
  vpn_gateway_monitoring = var.vpn_gateway_monitoring
  pip_monitoring = var.vpn_gateway_pip_monitoring
  log_analytics_workspace_id = module.log_analytics_workspace.law.id

  tags = local.hub_tags
}



# Log analytics workspace
module "log_analytics_workspace" {
  source = "../modules/resources/log-analytics-workspace"
  resource_group = azurerm_resource_group.hub_rg
  vnet = azurerm_virtual_network.hub_vnet
  name_prefix = local.hub_prefix

  tags = local.hub_tags
}

# Mgmt
resource "azurerm_subnet" "hub_mgmt_subnet" {
  name                 = "${local.hub_prefix}-mgmt-snet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.hub_mgmt_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "hub_mgmt_vm" {
  source = "../modules/resources/linux-vm"
  resource_group = azurerm_resource_group.hub_rg
  vnet = azurerm_virtual_network.hub_vnet
  name_prefix = "${local.hub_prefix}-mgmt"
  subnet_create = var.hub_mgmt_subnet_create
  subnet = azurerm_subnet.hub_mgmt_subnet
  subnet_address_prefixes = var.hub_mgmt_subnet_address_prefixes
  pip_create = true
  nic_enable_ip_forwarding = true
  vm_name = var.hub_mgmt_vm_name
  vm_publisher = var.vm_publisher
  vm_offer = var.vm_offer
  vm_sku = var.vm_sku
  vm_version = var.vm_version
  vm_create_option = var.vm_create_option
  vm_managed_disk_type = "Standard_LRS"
  vm_disk_size_gb = 128

  tags = merge({ 
    Category = "infra-mgmt"
  }, local.hub_tags)
}


# Container registry
module "container_registry" {
  source = "../modules/resources/container-registry"
  acr_name = var.acr_name
  name_prefix = local.hub_prefix
  resource_group = azurerm_resource_group.hub_rg
  admin_enabled = var.acr_admin_enabled

  tags = merge({ 
    Category = "acr"
  }, local.hub_tags)
}
