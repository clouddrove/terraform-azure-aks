provider "azurerm" {
  features {}
}

module "aks" {
  source      = "../.."
  name        = "app"
  environment = "test"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  kubernetes_version = "1.27"
  default_node_pool = {
    name                  = "agentpool"
    max_pods              = 200
    os_disk_size_gb       = 64
    vm_size               = "Standard_B2s"
    count                 = 1
    enable_node_public_ip = false
  }


  ##### if requred more than one node group.
  nodes_pools = [
    {
      name                  = "nodegroup2"
      max_pods              = 200
      os_disk_size_gb       = 64
      vm_size               = "Standard_B4ms"
      count                 = 2
      enable_node_public_ip = false
      mode                  = "User"
    },
  ]

  #networking
  vnet_id         = "/subscriptions/--------------<vnet_id>---------------"
  nodes_subnet_id = "/subscriptions/--------------<subnet_id>---------------"

  #### enable diagnostic setting.
  microsoft_defender_enabled = false
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = "/subscriptions/--------------<log_analytics_workspace_id>---------------"
}