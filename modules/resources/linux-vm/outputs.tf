output "vm" {
  value = azurerm_virtual_machine.vm
}

output "pip" {
  value = var.pip_create == true ? azurerm_public_ip.pip : null
}

output "vm_ssh" {
  value = tls_private_key.vm_ssh
}
