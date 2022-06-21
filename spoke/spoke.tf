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

resource "azurerm_subnet" "spoke_mgmt" {
    name                 = "${local.spoke_prefix}-mgmt"
    resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.spoke_vnet.name
    address_prefixes     = var.mgmt_address_prefixes

    // Must include (https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736)
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "spoke_workload" {
    name                 = "${local.spoke_prefix}-workload"
    resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.spoke_vnet.name
    address_prefixes     = var.workload_address_prefixes
}

resource "azurerm_network_interface" "spoke_nic" {
    name                 = "${local.spoke_prefix}-nic"
    location             = azurerm_resource_group.spoke_vnet_rg.location
    resource_group_name  = azurerm_resource_group.spoke_vnet_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = "${local.spoke_prefix}-ip-conf"
        subnet_id                     = azurerm_subnet.spoke_mgmt.id
        private_ip_address_allocation = "Dynamic"
    }
    
    tags = local.tags
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
        admin_password = var.vm_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
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

// Route table for spoke on hub network
resource "azurerm_route_table" "spoke_rt" {
    name                          = "${local.spoke_prefix}-rt"
    location                      = var.hub_nva_rg_location
    resource_group_name           = var.hub_nva_rg_name
    disable_bgp_route_propagation = false

    /* route {
        name                   = "toSpoke2"
        address_prefix         = "10.2.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.36"
    } */

    route {
        name           = "default"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VnetLocal"
    }

    tags = local.tags
}

resource "azurerm_route_table" "hub_gateway_rt" {
    name                          = "${var.hub_name}-to-${var.spoke_name}-gateway-rt"
    location                      = var.hub_nva_rg_location
    resource_group_name           = var.hub_nva_rg_name
    disable_bgp_route_propagation = false

    route {
        name                   = "to-${var.spoke_name}"
        address_prefix         = var.address_prefix
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.36"
    }

    tags = local.tags
}

resource "azurerm_subnet_route_table_association" "spoke_rt_spoke_vnet_mgmt" {
    subnet_id      = azurerm_subnet.spoke_mgmt.id
    route_table_id = azurerm_route_table.spoke_rt.id
    depends_on = [azurerm_subnet.spoke_mgmt]
}

resource "azurerm_subnet_route_table_association" "spoke_rt_spoke_vnet_workload" {
    subnet_id      = azurerm_subnet.spoke_workload.id
    route_table_id = azurerm_route_table.spoke_rt.id
    depends_on = [azurerm_subnet.spoke_workload]
}
