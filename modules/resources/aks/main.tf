# Key for VM
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = var.vnet_rg.location
    resource_group_name = var.vnet_rg.name
    dns_prefix          = var.dns_prefix
    depends_on =[var.subnet]
    #private_cluster_enabled = var.private_cluster_enabled

    network_profile {
        network_plugin      =   "azure"
        load_balancer_sku   =   "Standard"
    }
    
    role_based_access_control {
        enabled = true
    }
    
    linux_profile {
        admin_username = var.admin_username

        ssh_key {
            key_data = tls_private_key.vm_ssh.public_key_openssh
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = var.vm_size
        vnet_subnet_id  = var.subnet.id
        os_disk_size_gb = var.os_disk_size_gb 
    }

     
    identity {
        type = "SystemAssigned"
    }

    tags = local.tags
}
