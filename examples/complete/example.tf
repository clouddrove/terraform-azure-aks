provider "azurerm" {
  features {}
  subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
}
data "azurerm_client_config" "current_client_config" {}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "aks-test"
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
  version = "1.2.1"

  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  #subnet
  subnet_names    = ["default", "subnet-appw"]
  subnet_prefixes = ["10.30.0.0/20", "10.30.48.0/20"]


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
  version                          = "2.0.0"
  name                             = "app"
  environment                      = "test"
  label_order                      = ["name", "environment"]
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}

module "vault" {
  providers = {
    azurerm.dns_sub  = azurerm, #chagnge this to other alias if dns hosted in other subscription.
    azurerm.main_sub = azurerm
  }
  source  = "clouddrove/key-vault/azure"
  version = "1.2.0"
  name    = "appakstestcd2"
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
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable = true, need to add log analytics workspace id
}

module "aks" {
  source      = "../.."
  name        = "app1"
  environment = "test"
  depends_on  = [module.resource_group]

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  kubernetes_version      = "1.30.5"
  private_cluster_enabled = false
  default_node_pool = {
    name                  = "agentpool1"
    max_pods              = 200
    os_disk_size_gb       = 64
    vm_size               = "Standard_B4ms"
    count                 = 1
    enable_node_public_ip = false
    max_surge             = "33%"
  }
  gateway_id = module.application-gateway.application_gateway_id

  ##### if required more than one node group.
  # nodes_pools = [
  #   {
  #     name                  = "nodegroup2"
  #     max_pods              = 200
  #     os_disk_size_gb       = 64
  #     vm_size               = "Standard_B4ms"
  #     count                 = 
  #     enable_node_public_ip = false
  #     mode                  = "User"
  #     max_surge             = "33%"
  #   },
  # ]

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


module "application-gateway" {
  source              = "./app-gateway"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  subnet_id           = module.subnet.default_subnet_id[1]
  virtual_network_id  = module.vnet.vnet_id

  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  health_probes = [{
    name                = "healthProbe1"
    protocol            = "Http"
    host                = "127.0.0.1"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    }
  ]

  #front-end settings
  frontend_port_name             = "sappgw-feport"
  frontend_ip_configuration_name = "sappgw-feip"

  frontend_port_settings = [
    {
      name = "sappgw-feport-80"
      port = 80
    },
    {
      name = "sappgw-feport-443"
      port = 443
    }
  ]

  backend_address_pools = [
    {
      name         = "aks-backend-pool"
      ip_addresses = [] # This will be managed by AGIC
    }
  ]

  backend_http_settings = [
    {
      name                  = "aks-http-setting"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      port                  = 80
      enable_https          = false
      request_timeout       = 30
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300
      }
    }
  ]

  http_listeners = [
    {
      name                           = "aks-http-listener"
      frontend_ip_configuration_name = "sappgw-feip"
      frontend_port_name             = "sappgw-feport-80"
      ssl_certificate_name           = null
      host_name                      = null
    }
  ]

  request_routing_rules = [
    {
      name                       = "aks-routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "aks-http-listener"
      backend_address_pool_name  = "aks-backend-pool"
      backend_http_settings_name = "aks-http-setting"
      priority                   = 100
    }
  ]
}
