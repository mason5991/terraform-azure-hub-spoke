output "cluster_name" {
  value = module.aks.k8s.name
}

output "aks_linux_tls_public_key" {
  value = module.aks.vm_ssh.public_key_pem
  sensitive = true
}

output "aks_linux_tls_private_key" {
  value = module.aks.vm_ssh.private_key_pem
  sensitive = true
}

output "client_certificate" {
  value = module.aks.client_certificate
  sensitive = true
}

output "kube_config" {
  value = module.aks.kube_config
  sensitive = true
}
