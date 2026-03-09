data "azurerm_client_config" "current" {}

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
## Azure Kubernetes Service (AKS)
##-----------------------------------------------------------------------------
module "aks" {
  source                     = "../.."
  name                       = "core"
  environment                = "dev"
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  key_vault_id               = module.vault.id
  admin_objects_ids          = [data.azurerm_client_config.current_client_config.object_id]
  microsoft_defender_enabled = false
  diagnostic_setting_enable  = false
  vnet_id                    = module.vnet.vnet_id
  log_analytics_workspace_id = module.log-analytics.workspace_id
  default_node_pool_config = {
    enable_auto_scaling = false
    vnet_subnet_id      = module.subnet.subnet_ids.subnet1
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 32
  }
  # Microsoft Entra ID integration with Azure RBAC
  local_account_disabled = true
  admin_group_id         = ["<YOUR_ADMIN_GROUP_ID>"]

  role_based_access_control = [{
    managed            = true
    tenant_id          = data.azurerm_client_config.current.tenant_id # Required when azure_rbac_enabled = true
    azure_rbac_enabled = true                                         # Use Azure RBAC for Kubernetes authorization
  }]

  #Azure RBAC role assignments for namespace-level access
  aks_user_auth_role = [{
    scope                = "/subscriptions/0**5e1cabc60c/resourceGroups/public-app-test-resource-group/providers/Microsoft.ContainerService/managedClusters/app1-test-aks1/namespaces/test"
    role_definition_name = "Azure Kubernetes Service RBAC Admin"
    principal_id         = "***-**-***-**-***" # User or group object ID
  }]
}