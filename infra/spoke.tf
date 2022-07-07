locals {
    spoke_vnet_rg        = "${var.spoke_name}-vnet-rg"
    spoke_prefix         = var.spoke_name
    mntr_internal_prefix = "${var.spoke_name}-int"
    mntr_external_prefix = "${var.spoke_name}-ext"
    spoke_tags = merge({
      Terraform   = true
      Name        = var.spoke_name
      Type        = "spoke"
    }, var.tags)
}

resource "azurerm_resource_group" "spoke_vnet_rg" {
    name     = local.spoke_vnet_rg
    location = local.location

    tags = local.spoke_tags
}

# Spoke virtual network
resource "azurerm_virtual_network" "spoke_vnet" {
    name                = "${local.spoke_prefix}-vnet"
    location            = azurerm_resource_group.spoke_vnet_rg.location
    resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
    address_space       = var.spoke_vnet_address_space

    tags = local.spoke_tags
}

# Storage account
resource "azurerm_subnet" "storage_account_subnet" {
  name                 = "${local.spoke_prefix}-sg-snet"
  resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.storage_account_subnet_address_prefixes
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "storage_account" {
  source = "../modules/resources/storage-account"
  vnet_rg = azurerm_resource_group.spoke_vnet_rg
  vnet = azurerm_virtual_network.spoke_vnet
  name_prefix = local.spoke_prefix
  subnet_create = var.storage_account_subnet_create
  subnet = azurerm_subnet.storage_account_subnet
  subnet_address_prefixes = var.storage_account_subnet_address_prefixes
  network_rules = [{
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.mntr_internal_subnet.id, azurerm_subnet.mntr_external_subnet.id]
  }]

  storage_share = var.storage_share

  tags = local.spoke_tags
}



# Subnet for internal monitoring
resource "azurerm_subnet" "mntr_internal_subnet" {
  name                 = "${local.mntr_internal_prefix}-snet"
  resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.storage_account_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "mntr_internal_vm" {
  source = "../modules/resources/linux-vm"
  vnet_rg = azurerm_resource_group.spoke_vnet_rg
  vnet = azurerm_virtual_network.spoke_vnet
  name_prefix = local.mntr_internal_prefix
  subnet_create = var.mntr_internal_subnet_create
  subnet = azurerm_subnet.mntr_internal_subnet
  subnet_address_prefixes = var.mntr_internal_subnet_address_prefixes
  nic_enable_ip_forwarding = true
  vm_name = var.mntr_internal_vm_name
  vm_publisher = var.vm_publisher
  vm_offer = var.vm_offer
  vm_sku = var.vm_sku
  vm_version = var.vm_version
  vm_create_option = var.vm_create_option
  vm_managed_disk_type = var.vm_managed_disk_type
  vm_disk_size_gb = var.vm_disk_size_gb

  tags = merge({ 
    Category = "mntr-internal"
  }, local.spoke_tags)
}

# Subnet for external monitoring
resource "azurerm_subnet" "mntr_external_subnet" {
  name                 = "${local.mntr_external_prefix}-snet"
  resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.storage_account_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

module "mntr_external_vm" {
  source = "../modules/resources/linux-vm"
  vnet_rg = azurerm_resource_group.spoke_vnet_rg
  vnet = azurerm_virtual_network.spoke_vnet
  name_prefix = local.mntr_external_prefix
  subnet_create = var.mntr_external_subnet_create
  subnet = azurerm_subnet.mntr_external_subnet
  subnet_address_prefixes = var.mntr_external_subnet_address_prefixes
  nic_enable_ip_forwarding = true
  vm_name = var.mntr_external_vm_name
  vm_publisher = var.vm_publisher
  vm_offer = var.vm_offer
  vm_sku = var.vm_sku
  vm_version = var.vm_version
  vm_create_option = var.vm_create_option
  vm_managed_disk_type = var.vm_managed_disk_type
  vm_disk_size_gb = var.vm_disk_size_gb


  tags = merge({ 
    Category = "mntr-external"
  }, local.spoke_tags)
}

####################################################
##       Settings for connection with hub         ##
####################################################

// Network peering - spoke to hub
resource "azurerm_virtual_network_peering" "spoke_hub_peer" {
    name                      = "${local.spoke_prefix}-spoke-hub-peer"
    resource_group_name       = azurerm_resource_group.spoke_vnet_rg.name
    virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
    remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [azurerm_virtual_network.hub_vnet, azurerm_virtual_network.spoke_vnet]
}

// Network peering - hub to spoke
resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
    name                         = "${local.spoke_prefix}-hub-spoke-peer"
    resource_group_name          = azurerm_resource_group.hub_vnet_rg.name
    virtual_network_name         = azurerm_virtual_network.hub_vnet.name
    remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
    depends_on = [azurerm_virtual_network.hub_vnet, azurerm_virtual_network.spoke_vnet]
}
