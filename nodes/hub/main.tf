module "hub" {
  source = "../../modules/services/hub"

  hub_name = var.hub_name
  hub_location = var.hub_location
  vnet_address_space = var.vnet_address_space
  gateway_subnet_address_prefixes = var.gateway_subnet_address_prefixes
  firewall_subnet_address_prefixes = var.firewall_subnet_address_prefixes
  bastion_subnet_address_prefixes = var.bastion_subnet_address_prefixes
  mgmt_subnet_address_prefixes = var.mgmt_subnet_address_prefixes
  mgmt_vm_username = var.mgmt_vm_username
  mgmt_vm_size = var.mgmt_vm_size
  mgmt_vm_publisher = var.mgmt_vm_publisher
  mgmt_vm_offer = var.mgmt_vm_offer
  mgmt_vm_sku = var.mgmt_vm_sku
  mgmt_vm_version = var.mgmt_vm_version
  mgmt_vm_disk_name = var.mgmt_vm_disk_name
  mgmt_vm_disk_caching = var.mgmt_vm_disk_caching
  mgmt_vm_create_option = var.mgmt_vm_create_option
  mgmt_vm_managed_disk_type = var.mgmt_vm_managed_disk_type
  mgmt_vm_disk_size_gb = var.mgmt_vm_disk_size_gb
  tags = var.tags
}
