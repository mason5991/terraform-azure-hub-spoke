module "spoke" {
  source = "../../modules/services/spoke"

  spoke_location = var.spoke_location
  spoke_name = var.spoke_name
  hub_name = var.hub_name
  hub_vnet_id = var.hub_vnet_id
  hub_vnet_name = var.hub_vnet_name
  hub_vnet_rg_name = var.hub_vnet_rg_name
  vnet_address_space = var.vnet_address_space
  workload_address_prefixes = var.workload_address_prefixes
  vm_size = var.vm_size
  vm_publisher = var.vm_publisher
  vm_offer = var.vm_offer
  vm_sku = var.vm_sku
  vm_version = var.vm_version
  vm_create_option = var.vm_create_option
  vm_managed_disk_type = var.vm_managed_disk_type
  vm_disk_size_gb = var.vm_disk_size_gb
  tags = var.tags
}
