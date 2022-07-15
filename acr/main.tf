resource "azurerm_resource_group" "acr_rg" {
    name     = var.resource_group_name
    location = var.location

    tags = local.tags
}

# Main container registry
module "main_container_registry" {
  source = "../modules/resources/container-registry"
  acr_name = var.main_acr_name
  resource_group = azurerm_resource_group.acr_rg
  identity_ids = [data.azurerm_kubernetes_cluster.dev_k8s.kubelet_identity[0].user_assigned_identity_id]
  admin_enabled = true

  tags = merge(local.tags, {
    Name = "hydro"
  })
}

data "azurerm_kubernetes_cluster" "dev_k8s" {
  name = var.dev_k8s_name
  resource_group_name = var.dev_k8s_resource_group_name
}
