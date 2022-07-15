output "hub_rg_location" {
  value = azurerm_resource_group.hub_rg.location
}

output "hub_rg_id" {
  value = azurerm_resource_group.hub_rg.id
}

output "hub_rg_name" {
  value = azurerm_resource_group.hub_rg.name
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}

# Bastion
output "bastion_snet_id" {
  value = azurerm_subnet.bastion_subnet.id
}

output "bastion_id" {
  value = module.bastion.bastion.id
}

output "bastion_name" {
  value = module.bastion.bastion.name
}

output "bastion_public_ip" {
  value = module.bastion.pip.ip_address
}

# Firewall
output "firewall_snet_id" {
  value = azurerm_subnet.firewall_subnet.id
}

output "firewall_id" {
  value = module.firewall.firewall.id
}

output "firewall_name" {
  value = module.firewall.firewall.name
}

output "firewall_public_ip" {
  value = module.firewall.pip.ip_address
}

# Vpn gateway
output "vpn_gateway_snet_id" {
  value = azurerm_subnet.vpn_gateway_subnet.id
}

output "vpn_gateway_id" {
  value = module.vpn_gateway.vpn_gateway.id
}

output "vpn_gateway_name" {
  value = module.vpn_gateway.vpn_gateway.name
}

output "vpn_gateway_public_ip" {
  value = module.vpn_gateway.pip.ip_address
}


# Log analytics workspace
output "log_analytics_workspace_id" {
  value = module.log_analytics_workspace.law.id
}

output "log_analytics_workspace_name" {
  value = module.log_analytics_workspace.law.name
}

# Mgmt vm
output "hub_mgmt_subnet_id" {
  value = azurerm_subnet.hub_mgmt_subnet.id
}

output "hub_mgmt_subnet_name" {
  value = azurerm_subnet.hub_mgmt_subnet.name
}

output "hub_mgmt_vm_name" {
  value = module.hub_mgmt_vm.vm.name
}

output "hub_mgmt_vm_tls_public_key" {
  value = module.hub_mgmt_vm.vm_ssh.public_key_pem
  sensitive = true
}

output "hub_mgmt_vm_tls_private_key" {
  value = module.hub_mgmt_vm.vm_ssh.private_key_pem
  sensitive = true
}

################################################
##              Monitoring spoke              ##
################################################

output "spoke_rg_location" {
  value = azurerm_resource_group.spoke_rg.location
}

output "spoke_rg_id" {
  value = azurerm_resource_group.spoke_rg.id
}

output "spoke_rg_name" {
  value = azurerm_resource_group.spoke_rg.name
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke_vnet.name
}

# Storage account

output "storage_account_subnet_id" {
  value = azurerm_subnet.storage_account_subnet.id
}

output "storage_account_subnet_name" {
  value = azurerm_subnet.storage_account_subnet.name
}

# Internal mntr

output "mntr_internal_subnet_id" {
  value = azurerm_subnet.mntr_internal_subnet.id
}

output "mntr_internal_subnet_name" {
  value = azurerm_subnet.mntr_internal_subnet.name
}

output "mntr_internal_vm_name" {
  value = module.mntr_internal_vm.vm.name
}

output "mntr_internal_vm_tls_public_key" {
  value = module.mntr_internal_vm.vm_ssh.public_key_pem
  sensitive = true
}

output "mntr_internal_vm_tls_private_key" {
  value = module.mntr_internal_vm.vm_ssh.private_key_pem
  sensitive = true
}

# External mntr

output "mntr_external_subnet_id" {
  value = azurerm_subnet.mntr_external_subnet.id
}

output "mntr_external_subnet_name" {
  value = azurerm_subnet.mntr_external_subnet.name
}

output "mntr_external_vm_name" {
  value = module.mntr_external_vm.vm.name
}

output "mntr_external_vm_tls_public_key" {
  value = module.mntr_external_vm.vm_ssh.public_key_pem
  sensitive = true
}

output "mntr_external_vm_tls_private_key" {
  value = module.mntr_external_vm.vm_ssh.private_key_pem
  sensitive = true
}
