output "subnet" {
  value = azurerm_subnet.subnet
}

output "pip" {
  value = azurerm_public_ip.pip
}

output "bastion" {
  value = azurerm_bastion_host.bastion
}
