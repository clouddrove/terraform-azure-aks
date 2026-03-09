<!-- BEGIN_TF_DOCS -->

# Terraform Azure AKS (Azure Kubernetes Service)

This directory contains an example usage of the **terraform-azure-aks module**. It demonstrates how to deploy an Azure Kubernetes Service cluster with complete infrastructure including custom private DNS zones, Key Vault integration, Log Analytics monitoring, system and user node pools with auto-scaling enabled, node pool extensions, and Azure Kubernetes Fleet Manager for multi-cluster orchestration

---

## 📋 Requirements

| Name      | Version    |
|-----------|------------|
| Terraform | >= 1.6.6   |
| Azurerm   | >= 4.31.0 |

---

## 🔌 Providers

| Name    | Version |
|---------|---------|
| Azurerm   | >= 4.31.0 |

---

## 📦 Modules

| Name               | Source                                        | Version |
|--------------------|-----------------------------------------------|---------|
| resource_group     | terraform-az-modules/resource-group/azurerm   | 1.0.3   |
| vnet               | terraform-az-modules/vnet/azurerm             | 1.0.3   |
| subnet             | terraform-az-modules/subnet/azurerm           | 1.0.1   |
| log-analytics      | terraform-az-modules/log-analytics/azure      | 1.0.1   |
| vault              | terraform-az-modules/key-vault/azure          | 1.0.0   |
| private_dns_zone   | terraform-az-modules/private-dns/azure        | 1.0.1   |
| aks                | ../../                                        | n/a     |

---

## 🏗️ Resources

No resources are directly created in this example.

---

## 🔧 Inputs

No input variables are defined in this example.

---

## 📤 Outputs

| Name                                          | Description                                                      |
|-----------------------------------------------|------------------------------------------------------------------|
| `aks_id`                                      | The Kubernetes Managed Cluster ID                                |
| `current_kubernetes_version`                  | Current running Kubernetes version on the AKS cluster            |
| `fqdn`                                        | Public FQDN of the AKS cluster                                   |
| `private_fqdn`                                | Private FQDN when private link is enabled                        |
| `portal_fqdn`                                 | Azure Portal FQDN when private link is enabled                   |
| `oidc_issuer_url`                             | OIDC issuer URL associated with the AKS cluster                  |
| `node_resource_group`                         | Auto-generated resource group for AKS nodes                      |
| `node_resource_group_id`                      | ID of the node resource group                                    |
| `identity_principal_id`                       | Principal ID of the AKS managed identity                         |
| `identity_tenant_id`                          | Tenant ID of the AKS managed identity                            |
| `kube_config_raw`                             | Raw kubeconfig for user access                                   |
| `kube_admin_config_raw`                       | Raw kubeconfig for admin access (if local accounts enabled)      |
| `kube_config`                                 | Structured kube_config block (includes client credentials)       |
| `kube_admin_config`                           | Structured kube_admin_config block (includes client credentials) |
| `network_profile`                             | Network profile block of the AKS cluster                         |
| `lb_effective_outbound_ips`                   | Effective outbound IPs from Standard Load Balancer profile       |
| `natgw_effective_outbound_ips`                | Effective outbound IPs from NAT Gateway profile                  |
| `kubelet_identity_client_id`                  | Client ID for user-assigned identity of kubelets                 |
| `kubelet_identity_object_id`                  | Object ID for user-assigned identity of kubelets                 |
| `kubelet_identity_id`                         | Resource ID for user-assigned identity of kubelets               |
| `oms_agent_identity_client_id`                | Client ID of managed identity used by OMS Agents                 |
| `oms_agent_identity_object_id`                | Object ID of managed identity used by OMS Agents                 |
| `oms_agent_identity_id`                       | Resource ID of user-assigned identity used by OMS Agents         |
| `kv_secrets_provider_client_id`               | Client ID of managed identity used by Key Vault Secrets Provider |
| `kv_secrets_provider_object_id`               | Object ID of managed identity used by Key Vault Secrets Provider |
| `kv_secrets_provider_identity_id`             | Resource ID of user-assigned identity used by Key Vault Secrets Provider |
| `additional_node_pool_ids`                    | Map of additional node pool resource IDs                         |
| `additional_node_pool_names`                  | List of additional node pool names                               |
| `node_pool_configurations`                    | Complete configuration details of all node pools                 |
| `kubernetes_fleet_manager_id`                 | Kubernetes Fleet Manager ID                                      |
| `kubernetes_fleet_member_id`                  | Kubernetes Fleet Member ID                                       |
| `kubernetes_fleet_update_strategy_id`         | Kubernetes Fleet Update Strategy ID                              |
| `kubernetes_fleet_update_run_id`              | Kubernetes Fleet Update Run ID                                   |
| `kubernetes_flux_configuration_id`            | Kubernetes Flux Configuration ID                                 |
| `kubernetes_cluster_extension_id`             | Kubernetes Cluster Extension ID                                  |
| `kubernetes_cluster_extension_current_version`| Current version of Kubernetes Cluster Extension                  |
| `kubernetes_cluster_extension_identity_type`  | Identity type of Kubernetes Cluster Extension                    |
| `kubernetes_cluster_extension_principal_id`   | Principal ID of Kubernetes Cluster Extension managed identity    |
| `kubernetes_cluster_extension_tenant_id`      | Tenant ID of Kubernetes Cluster Extension managed identity       |

<!-- END_TF_DOCS -->