output "acr" {
  value = azurerm_container_registry.acr
}

output "user_assigned_identity" {
  value = azurerm_user_assigned_identity.registry_uai
}
