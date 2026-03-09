data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

data "azurerm_resources" "aks_nic" {
  depends_on = [azurerm_kubernetes_cluster.main]
  count      = var.enable && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  type       = "Microsoft.Network/networkInterfaces"
}

data "azurerm_resources" "aks_nsg" {
  depends_on = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count      = var.enable && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/networkSecurityGroups"
}

data "azurerm_resources" "aks_pip" {
  depends_on = [azurerm_kubernetes_cluster.main, azurerm_kubernetes_cluster_node_pool.main]
  count      = var.enable && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/publicIPAddresses"
}

data "azurerm_application_gateway" "appgw" {
  count               = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  name                = split("/", var.gateway_id)[8]
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "appgw_uami" {
  count               = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  name                = split("/", data.azurerm_application_gateway.appgw[0].identity[0].identity_ids[0])[8]
  resource_group_name = var.resource_group_name
}

data "azurerm_resource_group" "appgw_rg" {
  count = var.enable && var.enable_ingress_application_gateway ? 1 : 0
  name  = try(var.resource_group_name)
}