#############################
##      Vnet - Output      ##
#############################

output "spoke_vnet_rg_id" {
  value = azurerm_resource_group.spoke_vnet_rg.id
}

output "spoke_vnet_rg_location" {
  value = azurerm_resource_group.spoke_vnet_rg.location
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

#############################
##  Spoke VM SSH - Output  ##
#############################

output "spoke_vm_tls_public_key" {
  value = tls_private_key.spoke_vm_ssh.public_key_pem
  sensitive = true
}

output "hub_mgmt_vm_tls_private_key" {
  value = tls_private_key.spoke_vm_ssh.private_key_pem
  sensitive = true
}
