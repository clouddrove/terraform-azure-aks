output "name" {
  value       = azurerm_kubernetes_cluster.aks[0].name
  description = "Specifies the name of the AKS cluster."
}

output "id" {
  value       = azurerm_kubernetes_cluster.aks[0].id
  description = "Specifies the resource id of the AKS cluster."
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.aks[0].kube_config_raw
  description = "Contains the Kubernetes config to be used by kubectl and other compatible tools."
}

output "aks_system_identity_principal_id" {
  value       = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  description = "Content aks system identity's object id"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks[0].node_resource_group
  description = "Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}


