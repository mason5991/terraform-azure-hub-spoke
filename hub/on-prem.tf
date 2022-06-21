locals {
    onprem_location       = var.location
    onprem_resource_group = "onprem-vnet-rg"
    onprem_prefix         = "onprem"
}

resource "azurerm_resource_group" "onprem_vnet_rg" {
    name     = local.onprem_resource_group
    location = local.onprem_location
}

resource "azurerm_virtual_network" "onprem_vnet" {
    name                = "onprem-vnet"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name
    address_space       = ["192.168.0.0/16"]

    tags = {
      environment = local.onprem_prefix
    }
}

resource "azurerm_subnet" "onprem_gateway_subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.onprem_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.onprem_vnet.name
    address_prefixes     = ["192.168.255.224/27"]

    // Must include (https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736)
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "onprem_mgmt" {
    name                 = "mgmt"
    resource_group_name  = azurerm_resource_group.onprem_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.onprem_vnet.name
    address_prefixes     = ["192.168.1.128/25"]

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

resource "azurerm_public_ip" "onprem_pip" {
    name                = "${local.onprem_prefix}-pip"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name
    allocation_method   = "Dynamic"

    tags = {
        environment = local.onprem_prefix
    }
}

resource "azurerm_network_interface" "onprem_nic" {
    name                 = "${local.onprem_prefix}-nic"
    location             = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name  = azurerm_resource_group.onprem_vnet_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = local.onprem_prefix
        subnet_id                     = azurerm_subnet.onprem_mgmt.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.onprem_pip.id
    }

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem_nsg" {
    name                = "${local.onprem_prefix}-nsg"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "onprem"
    }
}

resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_association" {
    subnet_id                 = azurerm_subnet.onprem_mgmt.id
    network_security_group_id = azurerm_network_security_group.onprem_nsg.id

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

# Virtual Machine
resource "azurerm_virtual_machine" "onprem_vm" {
    name                  = "${local.onprem_prefix}-vm"
    location              = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name   = azurerm_resource_group.onprem_vnet_rg.name
    network_interface_ids = [azurerm_network_interface.onprem_nic.id]
    vm_size               = var.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "onprem-osdisk-1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.onprem_prefix}-vm"
        admin_username = var.vm_username
        admin_password = var.vm_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
      environment = local.onprem_prefix
    }
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "onprem_vpn_gateway_pip" {
    name                = "${local.onprem_prefix}-vpn-gateway-pip"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name

    allocation_method = "Dynamic"
}

# VPN Gateway for onprem network
resource "azurerm_virtual_network_gateway" "onprem_vpn_gateway" {
    name                = "onprem-vpn-gateway"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
        name                          = "vnetGatewayConfig"
        public_ip_address_id          = azurerm_public_ip.onprem_vpn_gateway_pip.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = azurerm_subnet.onprem_gateway_subnet.id
    }
    depends_on = [azurerm_public_ip.onprem_vpn_gateway_pip]
}
