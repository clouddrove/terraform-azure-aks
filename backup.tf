#---------------------------AKS backup----------------------------------------

resource "azurerm_data_protection_backup_vault" "backup_vault" {
  count               = var.enable && var.enable_backup == true ? 1 : 0
  name                = var.resource_position_prefix ? format("aks-backup-vault-%s", local.name) : format("%s-aks-backup-vault", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = var.vault_datastore_type
  redundancy          = var.aks_backup_redundancy
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "backup_policy" {
  count                           = var.enable && var.enable_backup == true ? 1 : 0
  name                            = var.resource_position_prefix ? format("aks-backup-policy-%s", local.name) : format("%s-aks-backup-policy", local.name)
  vault_name                      = azurerm_data_protection_backup_vault.backup_vault[0].name
  resource_group_name             = var.resource_group_name
  backup_repeating_time_intervals = ["R/2026-01-26T00:00:00Z/P1D"]
  dynamic "retention_rule" {
    for_each = var.retention_rules
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        duration        = retention_rule.value.life_cycle.duration
        data_store_type = retention_rule.value.life_cycle.data_store_type
      }
      criteria {
        absolute_criteria      = retention_rule.value.criteria.absolute_criteria
        days_of_week           = retention_rule.value.criteria.days_of_week
        months_of_year         = retention_rule.value.criteria.months_of_year
        weeks_of_month         = retention_rule.value.criteria.weeks_of_month
        scheduled_backup_times = retention_rule.value.criteria.scheduled_backup_times
      }
    }
  }
  dynamic "default_retention_rule" {
    for_each = var.default_retention_rules
    content {
      life_cycle {
        duration        = default_retention_rule.value.duration
        data_store_type = default_retention_rule.value.data_store_type
      }
    }
  }
}

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "aks_cluster_trusted_access" {
  count                 = var.enable && var.enable_backup == true ? 1 : 0
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main[0].id
  name                  = var.resource_position_prefix ? format("backup-rb-%s", local.name) : format("%s-backup-rb", local.name)
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.backup_vault[0].id
}

resource "azurerm_kubernetes_cluster_extension" "backup_cluster_extension" {
  count             = var.enable && var.enable_backup ? 1 : 0
  name              = var.resource_position_prefix ? format("aks-backup-extension-%s", local.name) : format("%s-aks-backup-extension", local.name)
  cluster_id        = azurerm_kubernetes_cluster.main[0].id
  extension_type    = "Microsoft.DataProtection.Kubernetes"
  release_train     = var.backup_release_train
  release_namespace = var.backup_release_namespace
  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                = var.backup_container_name
    "configuration.backupStorageLocation.config.resourceGroup"  = var.resource_group_name
    "configuration.backupStorageLocation.config.storageAccount" = var.backup_storage_account_name
    "configuration.backupStorageLocation.config.subscriptionId" = data.azurerm_client_config.current.subscription_id
    "credentials.tenantId"                                      = data.azurerm_client_config.current.tenant_id
  }
}

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "example" {
  count = var.enable && var.enable_backup == true ? 1 : 0
  name  = var.resource_position_prefix ? format("aks-backup-instance-cluster-%s", local.name) : format("%s-aks-backup-instance-cluster", local.name)
  location                     = var.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault[0].id
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.main[0].id
  snapshot_resource_group_name = var.snapshot_resource_group_name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.backup_policy[0].id
  backup_datasource_parameters {
    excluded_namespaces              = var.backup_datasource_parameters.excluded_namespaces
    excluded_resource_types          = var.backup_datasource_parameters.excluded_resource_types
    cluster_scoped_resources_enabled = var.backup_datasource_parameters.cluster_scoped_resources_enabled
    included_namespaces              = var.backup_datasource_parameters.included_namespaces
    included_resource_types          = var.backup_datasource_parameters.included_resource_types
    label_selectors                  = var.backup_datasource_parameters.label_selectors
    volume_snapshot_enabled          = var.backup_datasource_parameters.volume_snapshot_enabled
  }
  depends_on = [
    azurerm_role_assignment.test_extension_and_storage_account_permission,
    azurerm_role_assignment.test_vault_msi_read_on_cluster,
    azurerm_role_assignment.test_vault_msi_read_on_snap_rg,
    azurerm_role_assignment.test_cluster_msi_contributor_on_snap_rg,
    azurerm_role_assignment.test_vault_msi_snapshot_contributor_on_snap_rg,
    azurerm_role_assignment.test_vault_data_operator_on_snap_rg,
    azurerm_role_assignment.test_vault_data_contributor_on_storage,
  ]
}