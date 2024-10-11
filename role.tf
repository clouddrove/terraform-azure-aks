
resource "azurerm_role_assignment" "aks_entra_id" {
  count                = var.enabled && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? length(var.admin_group_id) : 0
  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_group_id[count.index]
}

# Allow aks system indentiy access to encrpty disc
resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enabled && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = azurerm_disk_encryption_set.main[0].id
  role_definition_name = "Contributor"
}

# Allow aks system indentiy access to ACR
resource "azurerm_role_assignment" "aks_acr_access_principal_id" {
  count                = var.enabled && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_acr_access_object_id" {
  count                = var.enabled && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  count                = var.enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks[0].node_resource_group)
  role_definition_name = "Network Contributor"
}

resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  name                = format("%s-aks-mid", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count                = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enabled && var.cmk_enabled ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

resource "azurerm_key_vault_key" "example" {
  depends_on      = [azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_enabled ? 1 : 0
  name            = format("%s-aks-encrypted-key", module.labels.id)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

resource "azurerm_disk_encryption_set" "main" {
  count               = var.enabled && var.cmk_enabled ? 1 : 0
  name                = format("%s-aks-dsk-encrpted", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
  key_vault_key_id    = var.key_vault_id != "" ? azurerm_key_vault_key.example[0].id : null

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "azurerm_disk_encryption_set_key_vault_access" {
  count                = var.enabled && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

## AKS user authentication with Azure Rbac. 
resource "azurerm_role_assignment" "example" {
  for_each = var.enabled && var.aks_user_auth_role != null ? { for k in var.aks_user_auth_role : k.principal_id => k } : null
  # scope                = 
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_key_vault_access_policy" "main" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = azurerm_disk_encryption_set.main[0].identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
  certificate_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

resource "azurerm_key_vault_access_policy" "kubelet_identity" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

resource "azurerm_role_assignment" "aks_system_object_id" {
  count                = var.enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "key_vault_secrets_provider" {
  count                = var.enabled && var.key_vault_secrets_provider_enabled ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_kubernetes_cluster.aks[0].key_vault_secrets_provider[0].secret_identity[0].object_id
}
