output "acr_rg_name" {
  value = azurerm_resource_group.acr_rg.name
}

output "acr_rg_location" {
  value = azurerm_resource_group.acr_rg.location
}

output "main_acr_id" {
  value = module.main_container_registry.acr.id
}

output "main_acr_name" {
  value = module.main_container_registry.acr.name
}

output "main_acr_login_server" {
  value = module.main_container_registry.acr.login_server
}

output "main_acr_identity_principal_id" {
  value = module.main_container_registry.acr.identity[0].principal_id
}

output "main_acr_identity_tenant_id" {
  value = module.main_container_registry.acr.identity[0].tenant_id
}

output "main_acr_admin_username" {
  value = module.main_container_registry.acr.admin_username
}

output "main_acr_admin_password" {
  value = module.main_container_registry.acr.admin_password
  sensitive = true
}

output "main_acr_uai_id" {
  value = module.main_container_registry.user_assigned_identity.id
}

output "main_acr_uai_client_id" {
  value = module.main_container_registry.user_assigned_identity.client_id
}

output "main_acr_uai_principal_id" {
  value = module.main_container_registry.user_assigned_identity.principal_id
}

output "main_acr_uai_tenant_id" {
  value = module.main_container_registry.user_assigned_identity.tenant_id
}
