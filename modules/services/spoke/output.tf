###############################
##  Resource group - Output  ##
###############################

output "spoke_rg" {
  value = azurerm_resource_group.spoke_vnet_rg.name
}

output "spoke_location" {
  value = azurerm_resource_group.spoke_vnet_rg.location
}

output "spoke_rg_id" {
  value = azurerm_resource_group.spoke_vnet_rg.id
}

#############################
##      Vnet - Output      ##
#############################

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke_vnet.name
}

################################
##  Workload Subnet - Output  ##
################################

output "spoke_workload_subnet_id" {
  value = azurerm_subnet.spoke_workload_subnet.id
}

output "spoke_workload_subnet_name" {
  value = azurerm_subnet.spoke_workload_subnet.name
}

##################################
##  Spoke workload VM - Output  ##
##################################

output "spoke_workload_vm_name" {
  value = azurerm_virtual_machine.spoke_workload_vm.name
}

output "spoke_workload_vm_tls_public_key" {
  value = tls_private_key.spoke_workload_vm_ssh.public_key_pem
  sensitive = true
}

output "spoke_workload_vm_tls_private_key" {
  value = tls_private_key.spoke_workload_vm_ssh.private_key_pem
  sensitive = true
}
