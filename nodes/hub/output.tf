#############################
##      Vnet - Output      ##
#############################

output "hub_vnet_rg_id" {
  value = module.hub.hub_vnet_rg_id
}

output "hub_vnet_id" {
  value = module.hub.hub_vnet_id
}

#############################
##     Bastion - Output    ##
#############################

output "hub_bastion_subnet_id" {
  value = module.hub.hub_bastion_subnet_id
}

output "hub_bastion_pip_id" {
  value = module.hub.hub_bastion_pip_id
}

output "hub_bastion_public_ip_address" {
  value = module.hub.hub_bastion_public_ip_address
}

#############################
##    Firewall - Output    ##
#############################

output "hub_firewall_subnet_id" {
  value = module.hub.hub_firewall_subnet_id
}

output "hub_firewall" {
  value = module.hub.hub_firewall
}

output "hub_firewall_pip_id" {
  value = module.hub.hub_firewall_pip_id
}

output "hub_firewall_public_ip_address" {
  value = module.hub.hub_firewall_public_ip_address
}

#############################
##  Log analytics - Output ##
#############################

output "hub_log_analytics_workspace_id" {
  value = module.hub.hub_log_analytics_workspace_id
}

#############################
##    Gateway - Output     ##
#############################

output "hub_gateway_subnet_id" {
  value = module.hub.hub_gateway_subnet_id
}

output "hub_vpn_gateway" {
  value = module.hub.hub_vpn_gateway
}

output "hub_vpn_gateway_pip_id" {
  value = module.hub.hub_vpn_gateway_pip_id
}

output "hub_vpn_gateway_public_ip_address" {
  value = module.hub.hub_vpn_gateway_public_ip_address
}

##################################
##       mgmt VM - Output       ##
##################################

output "hub_mgmt_vm_name" {
  value = module.hub.hub_mgmt_vm_name
}

output "hub_mgmt_vm_tls_public_key" {
  value = module.hub.hub_mgmt_vm_tls_public_key
  sensitive = true
}

output "hub_mgmt_vm_tls_private_key" {
  value = module.hub.hub_mgmt_vm_tls_private_key
  sensitive = true
}
