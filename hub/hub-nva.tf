# Virtual network appliance

locals {
    hub_nva_location       = var.location
    hub_nva_resource_group = "${var.hub_name}-nva-rg"
    hub_nva_prefix         = "${local.hub_prefix}-nva"
}

resource "azurerm_resource_group" "hub_nva_rg" {
    name     = local.hub_nva_resource_group
    location = local.hub_nva_location

    tags = local.tags
}

resource "azurerm_network_interface" "hub_nva_nic" {
    name                 = "${local.hub_nva_prefix}-nic"
    location             = azurerm_resource_group.hub_nva_rg.location
    resource_group_name  = azurerm_resource_group.hub_nva_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = "${local.hub_nva_prefix}-ip-conf"
        subnet_id                     = azurerm_subnet.hub_dmz.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.36"
    }

    tags = local.tags

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

# Virtual Machine
resource "azurerm_virtual_machine" "hub_nva_vm" {
    name                  = "${local.hub_nva_prefix}-vm"
    location              = azurerm_resource_group.hub_nva_rg.location
    resource_group_name   = azurerm_resource_group.hub_nva_rg.name
    network_interface_ids = [azurerm_network_interface.hub_nva_nic.id]
    vm_size               = var.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.hub_nva_prefix}-osdisk-1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.hub_nva_prefix}-vm"
        admin_username = var.vm_username
        admin_password = var.vm_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = local.tags
}

resource "azurerm_virtual_machine_extension" "enable_routes" {
    name                 = "enable-iptables-routes"
    virtual_machine_id   = azurerm_virtual_machine.hub_nva_vm.id
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"


    settings = <<SETTINGS
        {
            "fileUris": [
            "https://raw.githubusercontent.com/mspnp/reference-architectures/master/scripts/linux/enable-ip-forwarding.sh"
            ],
            "commandToExecute": "bash enable-ip-forwarding.sh"
        }
    SETTINGS

    tags = local.tags
}

resource "azurerm_route_table" "hub_gateway_rt" {
    name                          = "${local.hub_prefix}-gateway-rt"
    location                      = azurerm_resource_group.hub_nva_rg.location
    resource_group_name           = azurerm_resource_group.hub_nva_rg.name
    disable_bgp_route_propagation = false

    route {
        name           = "to-${var.hub_name}"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
    }

    /* route {
        name                   = "toSpoke1"
        address_prefix         = "10.1.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.36"
    }

    route {
        name                   = "toSpoke2"
        address_prefix         = "10.2.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.36"
    } */

    tags = local.tags
}

resource "azurerm_subnet_route_table_association" "hub_gateway_rt_hub_vnet_gateway_subnet" {
    subnet_id      = azurerm_subnet.hub_gateway_subnet.id
    route_table_id = azurerm_route_table.hub_gateway_rt.id
    depends_on     = [azurerm_subnet.hub_gateway_subnet]

    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

# For spoke 1
/* resource "azurerm_route_table" "spoke1-rt" {
    name                          = "spoke1-rt"
    location                      = azurerm_resource_group.hub-nva-rg.location
    resource_group_name           = azurerm_resource_group.hub-nva-rg.name
    disable_bgp_route_propagation = false

    route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
    }

    route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
    }

    tags = {
        environment = local.prefix-hub-nva
    }
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

resource "azurerm_subnet_route_table_association" "spoke1-rt-spoke1-vnet-mgmt" {
    subnet_id      = azurerm_subnet.spoke1-mgmt.id
    route_table_id = azurerm_route_table.spoke1-rt.id
    depends_on = [azurerm_subnet.spoke1-mgmt]
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

resource "azurerm_subnet_route_table_association" "spoke1-rt-spoke1-vnet-workload" {
    subnet_id      = azurerm_subnet.spoke1-workload.id
    route_table_id = azurerm_route_table.spoke1-rt.id
    depends_on = [azurerm_subnet.spoke1-workload]
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
} */

# For spoke 2
/* resource "azurerm_route_table" "spoke2-rt" {
    name                          = "spoke2-rt"
    location                      = azurerm_resource_group.hub-nva-rg.location
    resource_group_name           = azurerm_resource_group.hub-nva-rg.name
    disable_bgp_route_propagation = false

    route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_in_ip_address = "10.0.0.36"
    next_hop_type          = "VirtualAppliance"
    }

    route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
    }

    tags = {
    environment = local.prefix-hub-nva
    }
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

resource "azurerm_subnet_route_table_association" "spoke2-rt-spoke2-vnet-mgmt" {
    subnet_id      = azurerm_subnet.spoke2-mgmt.id
    route_table_id = azurerm_route_table.spoke2-rt.id
    depends_on = [azurerm_subnet.spoke2-mgmt]
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
}

resource "azurerm_subnet_route_table_association" "spoke2-rt-spoke2-vnet-workload" {
    subnet_id      = azurerm_subnet.spoke2-workload.id
    route_table_id = azurerm_route_table.spoke2-rt.id
    depends_on = [azurerm_subnet.spoke2-workload]
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }
} */
