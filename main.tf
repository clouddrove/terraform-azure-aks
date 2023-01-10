## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

## Vritual Network and Subnet Creation

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}


locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  default_agent_profile = {
    name                  = "agentpool"
    count                 = 1
    vm_size               = "Standard_D2_v3"
    os_type               = "Linux"
    enable_auto_scaling   = false
    min_count             = null
    max_count             = null
    type                  = "VirtualMachineScaleSets"
    node_taints           = null
    vnet_subnet_id        = var.nodes_subnet_id
    max_pods              = 30
    os_disk_type          = "Managed"
    os_disk_size_gb       = 128
    enable_node_public_ip = false
  }

  default_node_pool         = merge(local.default_agent_profile, var.default_node_pool)
  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
  nodes_pools               = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)]
  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 128
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 256
  }
}

module "labels" {

  source  = "clouddrove/labels/azure"
  version = "1.0.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

resource "azurerm_kubernetes_cluster" "aks" {
  count                            = var.enabled ? 1 : 0
  name                             = format("%s-aks", module.labels.id)
  location                         = local.location
  resource_group_name              = local.resource_group_name
  dns_prefix                       = replace(module.labels.id, "/[\\W_]/", "-")
  kubernetes_version               = var.kubernetes_version
  sku_tier                         = var.aks_sku_tier
  api_server_authorized_ip_ranges  = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
  node_resource_group              = var.node_resource_group
  enable_pod_security_policy       = var.enable_pod_security_policy
  disk_encryption_set_id           = var.azurerm_disk_encryption_set ? join("", azurerm_disk_encryption_set.main.*.id) : null
  private_cluster_enabled          = var.private_cluster_enabled
  private_dns_zone_id              = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type
  http_application_routing_enabled = var.enable_http_application_routing
  azure_policy_enabled             = var.enable_azure_policy
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control == null ? [] : var.role_based_access_control
    content {
      managed                = azure_active_directory_role_based_access_control.value.managed
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }

  }
  default_node_pool {
    name                = local.default_node_pool.name
    node_count          = local.default_node_pool.count
    vm_size             = local.default_node_pool.vm_size
    enable_auto_scaling = local.default_node_pool.enable_auto_scaling
    min_count           = local.default_node_pool.min_count
    max_count           = local.default_node_pool.max_count
    max_pods            = local.default_node_pool.max_pods
    os_disk_type        = local.default_node_pool.os_disk_type
    os_disk_size_gb     = local.default_node_pool.os_disk_size_gb
    type                = local.default_node_pool.type
    vnet_subnet_id      = local.default_node_pool.vnet_subnet_id
    node_taints         = local.default_node_pool.node_taints

  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? ["microsoft_defender"] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id = log_analytics_workspace_id
    }
  }

  identity {
    type = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? "UserAssigned" : "SystemAssigned"
  }


  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = cidrhost(var.service_cidr, 10)
    docker_bridge_cidr = var.docker_bridge_cidr
    service_cidr       = var.service_cidr
    load_balancer_sku  = "standard"
    outbound_type      = var.outbound_type

  }
  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
  ]
  tags = module.labels.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {

  count                 = length(local.nodes_pools)
  kubernetes_cluster_id = join("", azurerm_kubernetes_cluster.aks.*.id)
  name                  = local.nodes_pools[count.index].name
  vm_size               = local.nodes_pools[count.index].vm_size
  os_type               = local.nodes_pools[count.index].os_type
  os_disk_type          = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb       = local.nodes_pools[count.index].os_disk_size_gb
  vnet_subnet_id        = local.nodes_pools[count.index].vnet_subnet_id
  enable_auto_scaling   = local.nodes_pools[count.index].enable_auto_scaling
  node_count            = local.nodes_pools[count.index].count
  min_count             = local.nodes_pools[count.index].min_count
  max_count             = local.nodes_pools[count.index].max_count
  max_pods              = local.nodes_pools[count.index].max_pods
  enable_node_public_ip = local.nodes_pools[count.index].enable_node_public_ip
}

# Allow aks system indentiy access to encrpty disc
resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = join("", azurerm_disk_encryption_set.main.*.id)
  role_definition_name = "Contributor"
}

# Allow aks system indentiy access to ACR
resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enabled && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = var.acr_id
  role_definition_name = "Contributor"
}


# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  count                = var.enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, join("", azurerm_kubernetes_cluster.aks.*.node_resource_group))
  role_definition_name = "Contributor"
}

resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  name                = format("aks-%s-identity", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
}


resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = join("", azurerm_user_assigned_identity.aks_user_assigned_identity.*.principal_id)
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count                = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = join("", azurerm_user_assigned_identity.aks_user_assigned_identity.*.principal_id)
}

resource "azurerm_key_vault_key" "example" {
  count        = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0
  name         = format("aks-%s-vault-key", module.labels.id)
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "main" {
  count               = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0
  name                = format("aks-%s-dsk-encrpt", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
  key_vault_key_id    = var.azurerm_disk_encryption_set ? join("", azurerm_key_vault_key.example.*.id) : null

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "main" {
  count = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = azurerm_disk_encryption_set.main[0].identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.main[0].identity.0.principal_id
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
  count = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].key_vault_secrets_provider[0].secret_identity[0].object_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

resource "azurerm_key_vault_access_policy" "kubelet_identity" {
  count = var.enabled && var.azurerm_disk_encryption_set ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]

}
