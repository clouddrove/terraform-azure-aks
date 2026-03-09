<!-- BEGIN_TF_DOCS -->

# Terraform Azure AKS (Azure Kubernetes Service) with Backup

This directory demonstrates deploying an Azure Kubernetes Service cluster with Microsoft Entra ID integration, private networking, Key Vault integration, and Azure Backup for AKS workloads.

---

## 📋 Requirements

| Name      | Version    |
|-----------|------------|
| Terraform | >= 1.6.6   |
| Azurerm   | >= 4.31.0  |

---

## 🔌 Providers

| Name    | Version    |
|---------|------------|
| azurerm | >= 4.31.0  |

---

## 📦 Modules

| Name                | Source                                         | Version |
|---------------------|------------------------------------------------|---------|
| resource_group      | terraform-az-modules/resource-group/azurerm    | 1.0.3   |
| snapshot_resource_group | terraform-az-modules/resource-group/azurerm | 1.0.3   |
| vnet                | terraform-az-modules/vnet/azurerm              | 1.0.3   |
| subnet              | terraform-az-modules/subnet/azurerm            | 1.0.1   |
| log-analytics       | terraform-az-modules/log-analytics/azurerm     | 1.0.2   |
| private_dns_zone    | terraform-az-modules/private-dns/azurerm       | 1.0.2   |
| storage             | terraform-az-modules/storage/azurerm           | 1.0.0   |
| vault               | terraform-az-modules/key-vault/azurerm         | 1.0.1   |
| aks                 | ../..                                          | n/a     |

---

## 🏗️ Resources

No resources are directly created in this example.

---

## 🔧 Inputs

No input variables are defined in this example.

---

## 📤 Outputs

| Name                                    | Description                                                      |
|-----------------------------------------|------------------------------------------------------------------|
| `aks_id`                                | The Kubernetes Managed Cluster ID                                |
| `current_kubernetes_version`            | Current Kubernetes version on AKS cluster                        |
| `fqdn`                                  | Public FQDN of the AKS cluster                                   |
| `private_fqdn`                          | Private FQDN for private link                                    |
| `portal_fqdn`                           | Azure Portal FQDN for private link                               |
| `oidc_issuer_url`                       | OIDC issuer URL for workload identity                            |
| `node_resource_group`                   | Auto-generated node resource group                               |
| `node_resource_group_id`                | Node resource group ID                                           |
| `identity_principal_id`                 | AKS managed identity principal ID                                |
| `identity_tenant_id`                    | AKS managed identity tenant ID                                   |
| `kube_config_raw`                       | Raw kubeconfig for user access (sensitive)                       |
| `kube_admin_config_raw`                 | Raw kubeconfig for admin access (sensitive)                      |
| `kube_config`                           | Structured kube_config block                                     |
| `kube_admin_config`                     | Structured kube_admin_config block                               |
| `network_profile`                       | Network profile of AKS cluster                                   |
| `lb_effective_outbound_ips`             | Effective outbound IPs from Load Balancer                        |
| `natgw_effective_outbound_ips`          | Effective outbound IPs from NAT Gateway                          |
| `kubelet_identity_client_id`            | Kubelet identity client ID                                       |
| `kubelet_identity_object_id`            | Kubelet identity object ID                                       |
| `kubelet_identity_id`                   | Kubelet identity resource ID                                     |
| `kv_secrets_provider_client_id`         | Key Vault Secrets Provider client ID                             |
| `kv_secrets_provider_object_id`         | Key Vault Secrets Provider object ID                             |
| `kv_secrets_provider_identity_id`       | Key Vault Secrets Provider resource ID                           |

---