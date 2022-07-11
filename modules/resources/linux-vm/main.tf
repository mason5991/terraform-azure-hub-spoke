resource "azurerm_subnet" "subnet" {
    count                = var.subnet_create == true ? 1 : 0
    name                 = "${var.name_prefix}-snet"
    resource_group_name  = var.resource_group.name
    virtual_network_name = var.vnet.name
    address_prefixes     = var.subnet_address_prefixes

    // https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-1011183736
    enforce_private_link_endpoint_network_policies = var.subnet_enforce_private_link_endpoint_network_policies
}

resource "azurerm_public_ip" "pip" {
  count               = var.pip_create == true ? 1 : 0
  name                = "${var.name_prefix}-pip"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  
  allocation_method   = var.pip_allocation_method
  sku = var.pip_sku

  tags = local.tags
}

resource "azurerm_network_interface" "nic" {
    name                 = "${var.name_prefix}-nic"
    location             = var.resource_group.location
    resource_group_name  = var.resource_group.name
    enable_ip_forwarding = var.nic_enable_ip_forwarding

    ip_configuration {
        name                          = "${var.name_prefix}-snet-ip-conf"
        subnet_id                     = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
        private_ip_address_allocation = var.subnet_private_ip_address_allocation
        public_ip_address_id          = var.pip_create == true ? azurerm_public_ip.pip[0].id : null
    }
    
    tags = local.tags
}

resource "azurerm_network_security_group" "nsg" {
    name = "${var.name_prefix}-nsg"
    resource_group_name  = var.resource_group.name
    location             = var.resource_group.location
  
    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }

    tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
    subnet_id                 = var.subnet_create == true ? azurerm_subnet.subnet[0].id : var.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id

    timeouts {
        create = "2h"
        update = "2h"
        delete = "2h"
    }
}

# Key for VM
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Virtual machine
resource "azurerm_virtual_machine" "vm" {
    name                  = var.vm_name != "" ? var.vm_name : "${var.name_prefix}-vm"
    location              = var.resource_group.location
    resource_group_name   = var.resource_group.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    vm_size               = var.vm_size

    storage_image_reference {
        publisher = var.vm_publisher
        offer     = var.vm_offer
        sku       = var.vm_sku
        version   = var.vm_version
    }

    storage_os_disk {
        name              = var.vm_disk_name != "" ? var.vm_disk_name : "${var.vm_name}-osdisk-0"
        caching           = var.vm_disk_caching
        create_option     = var.vm_create_option
        managed_disk_type = var.vm_managed_disk_type
        disk_size_gb      = var.vm_disk_size_gb
    }

    os_profile {
        computer_name  = var.vm_name
        admin_username = var.vm_username
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            key_data = tls_private_key.vm_ssh.public_key_openssh
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
