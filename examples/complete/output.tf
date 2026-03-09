##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "aks_id" {
  value       = module.aks.aks_id
  description = "The Kubernetes Managed Cluster ID."
}

output "current_kubernetes_version" {
  value       = module.aks.current_kubernetes_version
  description = "Current running Kubernetes version on the AKS cluster."
}

output "fqdn" {
  value       = module.aks.fqdn
  description = "Public FQDN of the AKS cluster."
}

output "private_fqdn" {
  value       = module.aks.private_fqdn
  description = "Private FQDN when private link is enabled."
}

output "portal_fqdn" {
  value       = module.aks.portal_fqdn
  description = "Azure Portal FQDN when private link is enabled."
}

output "oidc_issuer_url" {
  value       = module.aks.oidc_issuer_url
  description = "OIDC issuer URL associated with the AKS cluster."
}

output "node_resource_group" {
  value       = module.aks.node_resource_group
  description = "Auto-generated resource group for AKS nodes."
}

output "node_resource_group_id" {
  value       = module.aks.node_resource_group_id
  description = "ID of the node resource group."
}

output "identity_principal_id" {
  value       = module.aks.identity_principal_id
  description = "Principal ID of the AKS managed identity."
}

output "identity_tenant_id" {
  value       = module.aks.identity_tenant_id
  description = "Tenant ID of the AKS managed identity."
}

output "kube_config_raw" {
  value       = module.aks.kube_config_raw
  description = "Raw kubeconfig for user access."
  sensitive   = true
}

output "kube_admin_config_raw" {
  value       = module.aks.kube_admin_config_raw
  description = "Raw kubeconfig for admin access (if local accounts enabled)."
  sensitive   = true
}

output "kube_config" {
  value       = module.aks.kube_config
  description = "Structured kube_config block (includes client credentials)."
  sensitive   = true
}

output "kube_admin_config" {
  value       = module.aks.kube_admin_config
  description = "Structured kube_admin_config block (includes client credentials)."
  sensitive   = true
}

output "network_profile" {
  value       = module.aks.network_profile
  description = "Network profile block of the AKS cluster."
}

output "lb_effective_outbound_ips" {
  value       = module.aks.lb_effective_outbound_ips
  description = "Effective outbound IPs from Standard Load Balancer profile."
}

output "natgw_effective_outbound_ips" {
  value       = module.aks.natgw_effective_outbound_ips
  description = "Effective outbound IPs from NAT Gateway profile."
}

output "aci_connector_identity_client_id" {
  value       = module.aks.aci_connector_identity_client_id
  description = "Client ID for user-assigned identity used by the ACI Connector."
}

output "aci_connector_identity_object_id" {
  value       = module.aks.aci_connector_identity_object_id
  description = "Object ID for user-assigned identity used by the ACI Connector."
}

output "aci_connector_identity_id" {
  value       = module.aks.aci_connector_identity_id
  description = "Resource ID for user-assigned identity used by the ACI Connector."
}

output "kubelet_identity_client_id" {
  value       = module.aks.kubelet_identity_client_id
  description = "Client ID for user-assigned identity of kubelets."
}

output "kubelet_identity_object_id" {
  value       = module.aks.kubelet_identity_object_id
  description = "Object ID for user-assigned identity of kubelets."
}

output "kubelet_identity_id" {
  value       = module.aks.kubelet_identity_id
  description = "Resource ID for user-assigned identity of kubelets."
}

output "ingress_appgw_effective_gateway_id" {
  value       = module.aks.ingress_appgw_effective_gateway_id
  description = "Application Gateway ID for AKS ingress controller."
}

output "ingress_appgw_identity_client_id" {
  value       = module.aks.ingress_appgw_identity_client_id
  description = "Client ID of managed identity for Application Gateway."
}

output "ingress_appgw_identity_object_id" {
  value       = module.aks.ingress_appgw_identity_object_id
  description = "Object ID of managed identity for Application Gateway."
}

output "ingress_appgw_identity_id" {
  value       = module.aks.ingress_appgw_identity_id
  description = "Resource ID of user-assigned identity for Application Gateway."
}

output "oms_agent_identity_client_id" {
  value       = module.aks.oms_agent_identity_client_id
  description = "Client ID of managed identity used by OMS Agents."
}

output "oms_agent_identity_object_id" {
  value       = module.aks.oms_agent_identity_object_id
  description = "Object ID of managed identity used by OMS Agents."
}

output "oms_agent_identity_id" {
  value       = module.aks.oms_agent_identity_id
  description = "Resource ID of user-assigned identity used by OMS Agents."
}

output "kv_secrets_provider_client_id" {
  value       = module.aks.kv_secrets_provider_client_id
  description = "Client ID of managed identity used by Key Vault Secrets Provider."
}

output "kv_secrets_provider_object_id" {
  value       = module.aks.kv_secrets_provider_object_id
  description = "Object ID of managed identity used by Key Vault Secrets Provider."
}

output "kv_secrets_provider_identity_id" {
  value       = module.aks.kv_secrets_provider_identity_id
  description = "Resource ID of user-assigned identity used by Key Vault Secrets Provider."
}

output "web_app_routing_identity_client_id" {
  value       = module.aks.web_app_routing_identity_client_id
  description = "Client ID of managed identity for Web App Routing."
}

output "web_app_routing_identity_object_id" {
  value       = module.aks.web_app_routing_identity_object_id
  description = "Object ID of managed identity for Web App Routing."
}

output "web_app_routing_identity_id" {
  value       = module.aks.web_app_routing_identity_id
  description = "Resource ID of user-assigned identity used for Web App Routing."
}

output "http_application_routing_zone_name" {
  value       = module.aks.http_application_routing_zone_name
  description = "Zone name for HTTP Application Routing add-on, if enabled."
}

output "kubernetes_flux_configuration_id" {
  description = "Kubernetes Flux Configuration ID"
  value       = module.aks.kubernetes_flux_configuration_id
}

output "kubernetes_fleet_update_strategy_id" {
  description = "Kubernetes Fleet Update Strategy ID"
  value       = module.aks.kubernetes_fleet_update_strategy_id
}

output "kubernetes_fleet_update_run_id" {
  description = "Kubernetes Fleet Update Run ID"
  value       = module.aks.kubernetes_fleet_update_run_id
}

output "kubernetes_fleet_member_id" {
  description = "Kubernetes Fleet Member ID"
  value       = module.aks.kubernetes_fleet_member_id
}

output "kubernetes_fleet_manager_id" {
  description = "Kubernetes Fleet Manager ID"
  value       = module.aks.kubernetes_fleet_manager_id
}

output "kubernetes_cluster_extension_id" {
  description = "Kubernetes Cluster Extension ID"
  value       = module.aks.kubernetes_cluster_extension_id
}

output "kubernetes_cluster_extension_current_version" {
  description = "Current version of Kubernetes Cluster Extension"
  value       = module.aks.kubernetes_cluster_extension_current_version
}

output "kubernetes_cluster_extension_identity_type" {
  description = "Identity type of Kubernetes Cluster Extension"
  value       = module.aks.kubernetes_cluster_extension_identity_type
}

output "kubernetes_cluster_extension_principal_id" {
  description = "Principal ID of Kubernetes Cluster Extension managed identity"
  value       = module.aks.kubernetes_cluster_extension_principal_id
}

output "kubernetes_cluster_extension_tenant_id" {
  description = "Tenant ID of Kubernetes Cluster Extension managed identity"
  value       = module.aks.kubernetes_cluster_extension_tenant_id
}