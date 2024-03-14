resource "azurerm_monitor_diagnostic_setting" "aks_diag" {
  depends_on                     = [azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enabled && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = format("%s-aks-diag-log", module.labels.id)
  target_resource_id             = azurerm_kubernetes_cluster.aks[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
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

resource "azurerm_monitor_diagnostic_setting" "pip_aks" {
  depends_on                     = [data.azurerm_resources.aks_pip, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enabled && var.diagnostic_setting_enable ? 1 : 0
  name                           = format("%s-aks-pip-diag-log", module.labels.id)
  target_resource_id             = data.azurerm_resources.aks_pip[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
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


resource "azurerm_monitor_diagnostic_setting" "aks-nsg" {
  depends_on                     = [data.azurerm_resources.aks_nsg, azurerm_kubernetes_cluster.aks]
  count                          = var.enabled && var.diagnostic_setting_enable ? 1 : 0
  name                           = format("%s-aks-nsg-diag-log", module.labels.id)
  target_resource_id             = data.azurerm_resources.aks_nsg[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

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

resource "azurerm_monitor_diagnostic_setting" "aks-nic" {
  depends_on                     = [data.azurerm_resources.aks_nic, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count                          = var.enabled && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  name                           = format("%s-aks-nic-dia-log", module.labels.id)
  target_resource_id             = data.azurerm_resources.aks_nic[count.index].resources[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
