##-----------------------------------------------------------------------------
## Permissions, Roles, and Policies
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "aks_entraid" {
  count                = var.enable && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? length(var.admin_group_id) : 0
  scope                = azurerm_kubernetes_cluster.main[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_group_id[count.index]
}

resource "azurerm_role_assignment" "aks_entraid_non_admin" {
  for_each             = var.enable && var.user_aks_roles != null && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? { for idx, val in local.user_aks_roles_flat : idx => val } : {}
  scope                = azurerm_kubernetes_cluster.main[0].id
  role_definition_name = each.value.role_definition
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enable && var.cmk_enabled ? 1 : 0
  principal_id         = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.main[0].identity[0].principal_id
  scope                = azurerm_disk_encryption_set.main[0].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "aks_acr_access_principal_id" {
  count                = var.enable && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.main[0].identity[0].principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_acr_access_object_id" {
  count                = var.enable && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_user_assigned" {
  count                = var.enable ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.main[0].node_resource_group)
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count                = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count                = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_secrets_provider" {
  count                = var.enable && var.key_vault_secrets_provider_enabled ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_kubernetes_cluster.main[0].key_vault_secrets_provider[0].secret_identity[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each = var.enable && var.cmk_enabled && var.admin_objects_ids != null ? {
    for idx, id in var.admin_objects_ids : idx => id
  } : {}
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "azurerm_disk_encryption_set_key_vault_access" {
  count                = var.enable && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "user_auth_role_assignment" {
  for_each             = var.enable && var.aks_user_auth_role != null ? { for k in var.aks_user_auth_role : k.principal_id => k } : {}
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  count               = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  name                = var.resource_position_prefix ? format("aks-mid-%s", local.name) : format("%s-aks-mid", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "extension_and_storage_account_permission" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.backup_storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.backup_cluster_extension[0].aks_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "extension_and_storage_blob_data_permission" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.backup_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.backup_cluster_extension[0].aks_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "vault_msi_read_on_cluster" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = azurerm_kubernetes_cluster.main[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "vault_msi_read_on_snap_rg" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.snapshot_resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "vault_msi_snapshot_contributor_on_snap_rg" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.snapshot_resource_group_id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "vault_data_operator_on_snap_rg" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.snapshot_resource_group_id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "vault_data_contributor_on_storage" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.backup_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "cluster_msi_contributor_on_snap_rg" {
  count                = var.enable && var.enable_backup == true ? 1 : 0
  scope                = var.snapshot_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.main[0].identity[0].principal_id
  depends_on = [
    azurerm_kubernetes_cluster.main
  ]
}

resource "azurerm_role_assignment" "app_gw_role" {
  count                = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  principal_id         = data.azurerm_user_assigned_identity.appgw_uami[0].principal_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.main[0].node_resource_group)
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "agic_appgw_contributor" {
  count                = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  scope                = var.gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.main]
}

resource "azurerm_role_assignment" "agic_rg_reader" {
  count                = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  scope                = data.azurerm_resource_group.appgw_rg[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.main]
}

resource "azurerm_role_assignment" "appgw_identity_operator" {
  count                = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  scope                = data.azurerm_user_assigned_identity.appgw_uami[0].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "appgw_subnet_join" {
  count                = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  scope                = data.azurerm_application_gateway.appgw[0].gateway_ip_configuration[0].subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main[0].ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

##-----------------------------------------------------------------------------
## Key Vault Access Policies
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "disk_policy" {
  count                   = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id            = var.key_vault_id
  tenant_id               = azurerm_disk_encryption_set.main[0].identity[0].tenant_id
  object_id               = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  key_permissions         = var.cmk_des_key_permissions
  certificate_permissions = var.cmk_des_certificate_permissions
}

resource "azurerm_key_vault_access_policy" "aks_policy" {
  count                   = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id            = var.key_vault_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.enable && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.main[0].identity[0].principal_id
  key_permissions         = var.cmk_aks_key_permissions
  certificate_permissions = var.cmk_aks_certificate_permissions
  secret_permissions      = var.cmk_aks_secret_permissions
}

resource "azurerm_key_vault_access_policy" "kubelet_policy" {
  count                   = var.enable && var.cmk_enabled ? 1 : 0
  key_vault_id            = var.key_vault_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_kubernetes_cluster.main[0].kubelet_identity[0].object_id
  key_permissions         = var.cmk_kubelet_key_permissions
  certificate_permissions = var.cmk_kubelet_certificate_permissions
  secret_permissions      = var.cmk_kubelet_secret_permissions
}