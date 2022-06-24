locals {
    spoke_location       = var.location
    spoke_resource_group = "${var.spoke_name}-vnet-rg"
    spoke_prefix         = "${var.spoke_name}"
}

resource "azurerm_resource_group" "spoke_vnet_rg" {
    name     = local.spoke_resource_group
    location = local.spoke_location

    tags = local.tags
}

resource "azurerm_virtual_network" "spoke_vnet" {
    name                = "${local.spoke_prefix}-vnet"
    location            = azurerm_resource_group.spoke_vnet_rg.location
    resource_group_name = azurerm_resource_group.spoke_vnet_rg.name
    address_space       = var.vnet_address_space

    tags = local.tags
}

resource "azurerm_subnet" "spoke_subnet" {
    name                 = "${local.spoke_prefix}-subnet"
    resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.spoke_vnet.name
    address_prefixes     = var.address_prefixes

    // Must include (https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736)
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_interface" "spoke_nic" {
    name                 = "${local.spoke_prefix}-nic"
    location             = azurerm_resource_group.spoke_vnet_rg.location
    resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = "${local.spoke_prefix}-subnet-ip-conf"
        subnet_id                     = azurerm_subnet.spoke_subnet.id
        private_ip_address_allocation = "Dynamic"
    }
    
    tags = local.tags
}

# Key for VM
resource "tls_private_key" "spoke_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Virtual machine
resource "azurerm_virtual_machine" "spoke_vm" {
    name                  = "${local.spoke_prefix}-vm"
    location              = azurerm_resource_group.spoke_vnet_rg.location
    resource_group_name   = azurerm_resource_group.spoke_vnet_rg.name
    network_interface_ids = [azurerm_network_interface.spoke_nic.id]
    vm_size               = var.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.spoke_prefix}-vm-osdisk-1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.spoke_prefix}-vm"
        admin_username = var.vm_username
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = tls_private_key.spoke_vm_ssh.public_key_openssh
            path = "/home/${var.vm_username}/.ssh/authorized_keys"
        } 
    }

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }

    tags = local.tags
}

/**
Below settings for connection with hub network
**/

// Network peering - spoke to hub
resource "azurerm_virtual_network_peering" "spoke_hub_peer" {
    name                      = "${local.spoke_prefix}-spoke-hub-peer"
    resource_group_name       = azurerm_resource_group.spoke_vnet_rg.name
    virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
    remote_virtual_network_id = var.hub_vnet_id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [azurerm_virtual_network.spoke_vnet]
}

// Network peering - hub to spoke
resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
    name                         = "${local.spoke_prefix}-hub-spoke-peer"
    resource_group_name          = var.hub_vnet_rg_name
    virtual_network_name         = var.hub_vnet_name
    remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
    depends_on = [azurerm_virtual_network.spoke_vnet]
}
