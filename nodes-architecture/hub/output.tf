#############################
##      Vnet - Output      ##
#############################

output "hub_vnet_rg_id" {
  value = azurerm_resource_group.hub_vnet_rg.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

#############################
##     Bastion - Output    ##
#############################

output "hub_bastion_subnet_id" {
  value = azurerm_subnet.hub_bastion_subnet.id
}

output "hub_bastion_pip_id" {
  value = azurerm_public_ip.hub_bastion_pip.id
}


#############################
##    Firewall - Output    ##
#############################

output "hub_firewall_subnet_id" {
  value = azurerm_subnet.hub_firewall_subnet.id
}

output "hub_firewall" {
  value = azurerm_firewall.hub_firewall
}

#############################
##  Log analytics - Output ##
#############################

output "hub_log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.hub_law.id
}

#############################
##    Gateway - Output     ##
#############################

output "hub_gateway_subnet_id" {
  value = azurerm_subnet.hub_gateway_subnet.id
}

output "hub_vpn_gateway" {
  value = azurerm_virtual_network_gateway.hub_vpn_gateway
}

#############################
##   Hub VM SSH - Output   ##
#############################

output "hub_mgmt_vm_tls_public_key" {
  value = tls_private_key.hub_vm_ssh.public_key_pem
  sensitive = true
}

output "hub_mgmt_vm_tls_private_key" {
  value = tls_private_key.hub_vm_ssh.private_key_pem
  sensitive = true
}
