output "name" {
  value       = try(azurerm_kubernetes_cluster.aks[0].name, null)
  description = "Specifies the name of the AKS cluster."
}

output "id" {
  value       = try(azurerm_kubernetes_cluster.aks[0].id, null)
  description = "Specifies the resource id of the AKS cluster."
}

output "kube_config_raw" {
  value       = try(azurerm_kubernetes_cluster.aks[0].kube_config_raw, null)
  description = "Contains the Kubernetes config to be used by kubectl and other compatible tools."
}

output "aks_system_identity_principal_id" {
  value       = try(azurerm_kubernetes_cluster.aks[0].identity[0].principal_id, null)
  description = "Content aks system identity's object id"
}

output "node_resource_group" {
  value       = try(azurerm_kubernetes_cluster.aks[0].node_resource_group, null)
  description = "Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}

output "key_vault_secrets_provider" {
  value = var.enabled && var.key_vault_secrets_provider_enabled ? azurerm_kubernetes_cluster.aks[0].key_vault_secrets_provider[0].secret_identity[0].object_id : null
  description = "Specifies the obejct id of key vault secrets provider "
}

