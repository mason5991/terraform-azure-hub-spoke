locals {
    hub_location       = var.location
    hub_resource_group = "${var.hub_name}-vnet-rg"
    shared_key         = var.shared_key
}

resource "azurerm_resource_group" "hub_vnet_rg" {
    name     = local.hub_resource_group
    location = local.hub_location

    tags = local.tags
}

# Hub virtual network
resource "azurerm_virtual_network" "hub_vnet" {
    name                = "${local.hub_prefix}-vnet"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name
    address_space       = ["10.0.0.0/16"]

    tags = local.tags
}

resource "azurerm_subnet" "hub_gateway_subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes     = ["10.0.255.224/27"]
}

resource "azurerm_subnet" "hub_mgmt" {
    name                 = "mgmt"
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes       = ["10.0.0.64/27"]

    // Must include (https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736)
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "hub_dmz" {
    name                 = "${local.hub_prefix}-dmz"
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes       = ["10.0.0.32/27"]
}

resource "azurerm_network_interface" "hub_nic" {
    name                 = "${local.hub_prefix}-nic"
    location             = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = "${local.hub_prefix}-ip-conf"
        subnet_id                     = azurerm_subnet.hub_mgmt.id
        private_ip_address_allocation = "Dynamic"
    }

    tags = local.tags

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

#Virtual Machine
resource "azurerm_virtual_machine" "hub_vm" {
    name                  = "${local.hub_prefix}-vm"
    location              = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name   = azurerm_resource_group.hub_vnet_rg.name
    network_interface_ids = [azurerm_network_interface.hub_nic.id]
    vm_size               = var.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.hub_prefix}-osdisk-1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.hub_prefix}-vm"
        admin_username = var.vm_username
        admin_password = var.vm_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = local.tags
}

# Public IP for Virtual Network Gateway
resource "azurerm_public_ip" "hub_vpn_gateway_pip" {
    name                = "${local.hub_prefix}-vpn-gateway-pip"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name

    allocation_method = "Dynamic"
    
    tags = local.tags
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "hub_vnet_gateway" {
    name                = "${local.hub_prefix}-vpn-gateway"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
        name                          = "${local.hub_prefix}-vnet-gateway-ip-conf"
        public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = azurerm_subnet.hub_gateway_subnet.id
    }

    depends_on = [azurerm_public_ip.hub_vpn_gateway_pip]
    
    tags = local.tags
}

# Connection - hub gateway to onprem gateway
resource "azurerm_virtual_network_gateway_connection" "hub_onprem_conn" {
    name                = "${local.hub_prefix}-onprem-conn"
    location            = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name = azurerm_resource_group.hub_vnet_rg.name

    type           = "Vnet2Vnet"
    routing_weight = 1

    virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub_vnet_gateway.id
    peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vpn_gateway.id

    shared_key = local.shared_key
    
    tags = local.tags
}

# Connection - onprem gateway to hub gateway
resource "azurerm_virtual_network_gateway_connection" "onprem_hub_conn" {
    name                = "onprem-hub-conn"
    location            = azurerm_resource_group.onprem_vnet_rg.location
    resource_group_name = azurerm_resource_group.onprem_vnet_rg.name
    type                            = "Vnet2Vnet"
    routing_weight = 1
    virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem_vpn_gateway.id
    peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_vnet_gateway.id

    shared_key = local.shared_key
    
    tags = local.tags
}
