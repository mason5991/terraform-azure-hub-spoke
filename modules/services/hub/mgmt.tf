# For mgmt
resource "azurerm_subnet" "hub_mgmt" {
    name                 = "${local.hub_prefix}-mgmt-subnet"
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    address_prefixes       = var.mgmt_subnet_address_prefixes

    // Must include (https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736)
    enforce_private_link_endpoint_network_policies = true

    timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
  }
}

resource "azurerm_public_ip" "hub_mgmt_pip" {
  name                = "${local.hub_prefix}-mgmt-pip"
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  location            = azurerm_resource_group.hub_vnet_rg.location
  
  allocation_method   = "Static"
  sku = "Standard"

  tags = local.tags
}

resource "azurerm_network_interface" "hub_mgmt_nic" {
    name                 = "${local.hub_prefix}-mgmt-nic"
    location             = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    enable_ip_forwarding = true

    ip_configuration {
        name                          = "${local.hub_prefix}-mgmt-ip-conf"
        subnet_id                     = azurerm_subnet.hub_mgmt.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.hub_mgmt_pip.id
    }
    depends_on = [azurerm_subnet.hub_mgmt,azurerm_public_ip.hub_mgmt_pip]
    tags = local.tags

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }
}

resource "azurerm_network_security_group" "hub_mgmt_nsg" {
    name = "${local.hub_prefix}-mgmt-nsg"
    resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
    location             = azurerm_resource_group.hub_vnet_rg.location
    
    tags = local.tags

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }
}

# Key for VM
resource "tls_private_key" "hub_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Virtual Machine
resource "azurerm_virtual_machine" "hub_mgmt_vm" {
    name                  = "${local.hub_prefix}-mgmt-vm"
    location              = azurerm_resource_group.hub_vnet_rg.location
    resource_group_name   = azurerm_resource_group.hub_vnet_rg.name
    network_interface_ids = [azurerm_network_interface.hub_mgmt_nic.id]
    vm_size               = var.mgmt_vm_size

    storage_image_reference {
        publisher = var.mgmt_vm_publisher
        offer     = var.mgmt_vm_offer
        sku       = var.mgmt_vm_sku
        version   = var.mgmt_vm_version
    }

    storage_os_disk {
        name              = var.mgmt_vm_disk_name != "" ? var.mgmt_vm_disk_name : "${local.hub_prefix}-mgmt-osdisk-0"
        caching           = var.mgmt_vm_disk_caching
        create_option     = var.mgmt_vm_create_option
        managed_disk_type = var.mgmt_vm_managed_disk_type
    }

    os_profile {
        computer_name  = "${local.hub_prefix}-mgmt-vm"
        admin_username = var.mgmt_vm_username
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = tls_private_key.hub_vm_ssh.public_key_openssh
            path = "/home/${var.mgmt_vm_username}/.ssh/authorized_keys"
        } 
    }

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }

    tags = local.tags
}
