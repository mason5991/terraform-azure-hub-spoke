output "vm_name" {
  value = module.spoke.spoke_workload_vm_name
}

output "vm_tls_public_key" {
  value = module.spoke.spoke_workload_vm_tls_public_key
  sensitive = true
}

output "vm_tls_private_key" {
  value = module.spoke.spoke_workload_vm_tls_private_key
  sensitive = true
}
