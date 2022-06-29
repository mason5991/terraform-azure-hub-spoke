module "spoke" {
  source = "../../../modules/services/spoke"

  spoke_location = var.spoke_location
  spoke_name = var.spoke_name
  hub_name = var.hub_name
  hub_vnet_id = var.hub_vnet_id
  hub_vnet_name = var.hub_vnet_name
  hub_vnet_rg_name = var.hub_vnet_rg_name
  vnet_address_space = var.vnet_address_space
  workload_address_prefixes = var.workload_address_prefixes
}
