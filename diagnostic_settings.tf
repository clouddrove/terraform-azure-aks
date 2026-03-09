##-----------------------------------------------------------------------------
## Diagnostic Settings
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "diag" {
  depends_on                     = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-diag-log-%s", local.name) : format("%s-aks-diag-log", local.name)
  target_resource_id             = azurerm_kubernetes_cluster.main[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.kv_logs.enabled ? var.kv_logs.category != null ? var.kv_logs.category : var.kv_logs.category_group : []
    content {
      category       = var.kv_logs.category != null ? enabled_log.value : null
      category_group = var.kv_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip_diag" {
  depends_on                     = [data.azurerm_resources.aks_pip, azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-pip-diag-log-%s", local.name) : format("%s-aks-pip-diag-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_pip[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.pip_logs.enabled ? var.pip_logs.category != null ? var.pip_logs.category : var.pip_logs.category_group : []
    content {
      category       = var.pip_logs.category != null ? enabled_log.value : null
      category_group = var.pip_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_diag" {
  depends_on                     = [data.azurerm_resources.aks_nsg, azurerm_kubernetes_cluster.main]
  count                          = var.enable && var.diagnostic_setting_enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nsg-diag-log-%s", local.name) : format("%s-aks-nsg-diag-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_nsg[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.kv_logs.enabled ? var.kv_logs.category != null ? var.kv_logs.category : var.kv_logs.category_group : []
    content {
      category       = var.kv_logs.category != null ? enabled_log.value : null
      category_group = var.kv_logs.category == null ? enabled_log.value : null
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

resource "azurerm_monitor_diagnostic_setting" "nic_diag" {
  depends_on                     = [data.azurerm_resources.aks_nic, azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count                          = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = var.resource_position_prefix ? format("aks-nic-dia-log-%s", local.name) : format("%s-aks-nic-dia-log", local.name)
  target_resource_id             = data.azurerm_resources.aks_nic[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}