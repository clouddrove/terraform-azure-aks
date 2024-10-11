provider "azurerm" {
  features {}
  subscription_id = "000000-11111-1223-XXX-XXXXXXXXXXXX"
}

provider "azurerm" {
  features {}
  alias           = "peer"
  subscription_id = "000000-11111-1223-XXX-XXXXXXXXXXXX"
}

data "azurerm_client_config" "current_client_config" {}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "app-public"
  environment = "test"
  label_order = ["name", "environment", ]
  location    = "Canada Central"
}

module "vnet" {
  source  = "clouddrove/vnet/azure"
  version = "1.0.4"

  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.30.0.0/16"]
}

module "subnet" {
  source  = "clouddrove/subnet/azure"
  version = "1.2.0"

  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  #subnet
  subnet_names    = ["default"]
  subnet_prefixes = ["10.30.0.0/20"]

  # route_table
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.1.0"
  name                             = "app"
  environment                      = "test"
  label_order                      = ["name", "environment"]
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  log_analytics_workspace_id       = module.log-analytics.workspace_id
}

module "vault" {
  source  = "clouddrove/key-vault/azure"
  version = "1.2.0"
  name    = "apptest5rds4556"
  providers = {
    azurerm.dns_sub  = azurerm.peer, #change this to other alias if dns hosted in other subscription.
    azurerm.main_sub = azurerm
  }
  #environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  virtual_network_id  = module.vnet.vnet_id
  subnet_id           = module.subnet.default_subnet_id[0]

  public_network_access_enabled = true

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }

  ##RBAC
  enable_rbac_authorization = true
  reader_objects_ids        = [data.azurerm_client_config.current_client_config.object_id]
  admin_objects_ids         = [data.azurerm_client_config.current_client_config.object_id]
  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable = true, need to add log analytics workspace id
}

module "aks" {
  source              = "../.."
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  kubernetes_version      = "1.28.9"
  private_cluster_enabled = false

  default_node_pool = {
    name                  = "agentpool1"
    max_pods              = 200
    os_disk_size_gb       = 64
    vm_size               = "Standard_B4ms"
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
  vnet_id         = module.vnet.vnet_id
  nodes_subnet_id = module.subnet.default_subnet_id[0]

  # acr_id       = "****" #pass this value if you  want aks to pull image from acr else remove it
  key_vault_id      = module.vault.id #pass this value of variable 'cmk_enabled = true' if you want to enable Encryption with a Customer-managed key else remove it.
  admin_objects_ids = [data.azurerm_client_config.current_client_config.object_id]

  #### enable diagnostic setting.
  microsoft_defender_enabled = true
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id # when diagnostic_setting_enable = true && oms_agent_enabled = true
}
