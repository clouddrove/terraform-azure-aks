##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    },
    {
      name            = "subnet-appgw"
      subnet_prefixes = ["10.0.2.0/24"]
    }
  ]
}

##-----------------------------------------------------------------------------
## Log Analytics Workspace
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "1.0.2"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Private DNS Zone
##-----------------------------------------------------------------------------
module "private_dns_zone" {
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.2"
  location            = module.resource_group.resource_group_location
  name                = "dns"
  environment         = "dev"
  resource_group_name = module.resource_group.resource_group_name
  label_order         = ["name", "environment", "location"]
  private_dns_config = [
    {
      resource_type = "azure_kubernetes"
      vnet_ids      = [module.vnet.vnet_id]
    },
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

##-----------------------------------------------------------------------------
## Key Vault
##-----------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.0.1"
  name                          = "core"
  environment                   = "dev"
  custom_name                   = "dahibadewihchole"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  sku_name                      = "premium"
  private_dns_zone_ids          = module.private_dns_zone.private_dns_zone_ids.key_vault
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## WAF
##-----------------------------------------------------------------------------
module "waf" {
  source              = "terraform-az-modules/waf/azurerm"
  version             = "1.0.1"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  policy_enabled      = true
  policy_mode         = "Detection"
  managed_rule_set_configuration = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]
}

##------------------------------------------------------------------------------
## Application Gateway
##------------------------------------------------------------------------------
module "application_gateway" {
  source               = "terraform-az-modules/application-gateway/azurerm"
  version              = "1.0.1"
  name                 = "core"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  location             = module.resource_group.resource_group_location
  resource_group_name  = module.resource_group.resource_group_name
  firewall_policy_id   = module.waf.waf_policy_id
  external_waf_enabled = true
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
  gateway_ip_configuration_name  = "appgw-gwipc"
  subnet_id                      = module.subnet.subnet_ids["subnet-appgw"]
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
      ip_addresses = []
    }
  ]
  backend_http_settings = [
    {
      name                  = "aks-http-setting"
      cookie_based_affinity = "Disabled"
      enable_https          = false
      path                  = "/"
      port                  = 80
      protocol              = "Http"
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
##-----------------------------------------------------------------------------
## Azure Kubernetes Service (AKS)
##-----------------------------------------------------------------------------
module "aks" {
  depends_on              = [module.application_gateway]
  source                  = "../../"
  name                    = "core"
  environment             = "dev"
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.resource_group_location
  private_dns_zone_id     = module.private_dns_zone.private_dns_zone_ids.azure_kubernetes
  private_cluster_enabled = true
  vnet_id                 = module.vnet.vnet_id
  default_node_pool_config = {
    enable_auto_scaling = false
    vnet_subnet_id      = module.subnet.subnet_ids.subnet1
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 32
  }
  key_vault_id                       = module.vault.id
  admin_objects_ids                  = [data.azurerm_client_config.current_client_config.object_id]
  microsoft_defender_enabled         = false
  diagnostic_setting_enable          = false
  log_analytics_workspace_id         = module.log-analytics.workspace_id
  gateway_id                         = module.application_gateway.application_gateway_id
  enable_ingress_application_gateway = true
  ingress_application_gateway = {
    gateway_id = module.application_gateway.application_gateway_id
  }
}