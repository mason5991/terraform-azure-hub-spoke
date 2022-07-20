output "subnet" {
  value = azurerm_subnet.subnet
}

output "pip" {
  value = azurerm_public_ip.pip
}

output "application_gateway" {
  value = azurerm_application_gateway.application_gateway
}
