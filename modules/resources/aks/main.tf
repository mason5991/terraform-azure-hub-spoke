# Key for VM
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = var.resource_group.location
    resource_group_name = var.resource_group.name
    dns_prefix          = var.dns_prefix
    depends_on =[var.subnet]
    #private_cluster_enabled = var.private_cluster_enabled
    public_network_access_enabled = var.public_network_access_enabled
    sku_tier = var.sku_tier

    network_profile {
        network_plugin      =   "azure"
        load_balancer_sku   =   var.load_balancer_sku
    }
    
    role_based_access_control_enabled = var.role_based_access_control_enabled
    
    linux_profile {
        admin_username = var.admin_username

        ssh_key {
            key_data = tls_private_key.vm_ssh.public_key_openssh
        }
    }

    default_node_pool {
        name            = var.default_node_pool_name
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
