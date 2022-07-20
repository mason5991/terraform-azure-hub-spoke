output "resource_group_name" {
  value = azurerm_resource_group.k8s_rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.k8s_rg.location
}

output "subnet_name" {
  value = azurerm_subnet.k8s_subnet.name
}

output "cluster_name" {
  value = module.dev_k8s.k8s.name
}

output "aks_linux_tls_public_key" {
  value = module.dev_k8s.vm_ssh.public_key_pem
  sensitive = true
}

output "aks_linux_tls_private_key" {
  value = module.dev_k8s.vm_ssh.private_key_pem
  sensitive = true
}

output "client_certificate" {
  value = module.dev_k8s.client_certificate
  sensitive = true
}

output "kube_config" {
  value = module.dev_k8s.k8s.kube_config
  sensitive = true
}

output "kube_admin_config" {
  value = module.dev_k8s.k8s.kube_admin_config
  sensitive = true
}

output "aks" {
  value = module.dev_k8s.k8s
  sensitive = true
}

output "identity" {
  value = module.dev_k8s.k8s.identity
}

output "kubelet_identity" {
  value = module.dev_k8s.k8s.kubelet_identity
}
