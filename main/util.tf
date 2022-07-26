locals {
    util_spoke_rg             = "${var.util_spoke_name}-rg"
    util_spoke_prefix         = var.util_spoke_name
    ansible_name              = "ansible"
    ansible_vm_name           = "${local.ansible_name}-server"
    util_spoke_tags = merge({
      Terraform   = true
      Name        = var.util_spoke_name
      Type        = "spoke"
    }, var.tags)
}

resource "azurerm_resource_group" "util_spoke_rg" {
    name     = local.util_spoke_rg
    location = local.location

    tags = local.util_spoke_tags
}

# Spoke virtual network
resource "azurerm_virtual_network" "util_spoke_vnet" {
    name                = "${local.util_spoke_prefix}-vnet"
    location            = azurerm_resource_group.util_spoke_rg.location
    resource_group_name = azurerm_resource_group.util_spoke_rg.name
    address_space       = var.util_spoke_vnet_address_space

    tags = local.util_spoke_tags
}


# Subnet for ansible
resource "azurerm_subnet" "ansible_subnet" {
  name                 = "${local.ansible_name}-snet"
  resource_group_name  = azurerm_resource_group.util_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.util_spoke_vnet.name
  address_prefixes     = var.ansible_subnet_address_prefixes

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

# Ansible server
module "ansible_vm" {
  source = "../modules/resources/linux-vm"
  resource_group = azurerm_resource_group.util_spoke_rg
  vnet = azurerm_virtual_network.util_spoke_vnet
  name_prefix = local.ansible_name
  subnet_create = false
  subnet = azurerm_subnet.ansible_subnet
  subnet_address_prefixes = var.ansible_subnet_address_prefixes
  nic_enable_ip_forwarding = true
  vm_name = local.ansible_vm_name
  vm_publisher = var.vm_publisher
  vm_offer = var.vm_offer
  vm_sku = var.vm_sku
  vm_size = "Standard_D4s_v3"
  vm_version = var.vm_version
  vm_create_option = var.vm_create_option
  vm_managed_disk_type = var.vm_managed_disk_type
  vm_disk_size_gb = var.vm_disk_size_gb

  tags = merge({ 
    Category = local.ansible_name
  }, local.util_spoke_tags)
}

# Ansible server public IP
resource "azurerm_public_ip" "ansible_pip" {
  name                = "${local.ansible_name}-pip"
  location            = azurerm_resource_group.util_spoke_rg.location
  resource_group_name = azurerm_resource_group.util_spoke_rg.name

  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge({ 
    Category = local.ansible_name
  }, local.util_spoke_tags)
}

####################################################
##       Settings for connection with hub         ##
####################################################

// Network peering - spoke to hub
resource "azurerm_virtual_network_peering" "util_spoke_hub_peer" {
    name                      = "${local.util_spoke_prefix}-spoke-hub-peer"
    resource_group_name       = azurerm_resource_group.util_spoke_rg.name
    virtual_network_name      = azurerm_virtual_network.util_spoke_vnet.name
    remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [azurerm_virtual_network.hub_vnet, azurerm_virtual_network.util_spoke_vnet, module.vpn_gateway]
}

// Network peering - hub to spoke
resource "azurerm_virtual_network_peering" "util_hub_spoke_peer" {
    name                         = "${local.util_spoke_prefix}-hub-spoke-peer"
    resource_group_name          = azurerm_resource_group.hub_rg.name
    virtual_network_name         = azurerm_virtual_network.hub_vnet.name
    remote_virtual_network_id    = azurerm_virtual_network.util_spoke_vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
    depends_on = [azurerm_virtual_network.hub_vnet, azurerm_virtual_network.util_spoke_vnet, module.vpn_gateway]
}
