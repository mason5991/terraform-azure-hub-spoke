output "subnet" {
  value = azurerm_subnet.subnet
}

output "pip" {
  value = azurerm_public_ip.pip
}

output "vpn_gateway" {
  value = azurerm_virtual_network_gateway.vpn_gateway
}
