output "k8s" {
  value = azurerm_kubernetes_cluster.k8s
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw

  sensitive = true
}

output "vm_ssh" {
  value = tls_private_key.vm_ssh
}
