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

module "snapshot_resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "snapshot"
  environment = "dev"
  location    = "eastus"
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
      resource_type = "azure_kubernetes"
      vnet_ids      = [module.vnet.vnet_id]
    },
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

module "storage" {
  source                        = "terraform-az-modules/storage/azurerm"
  version                       = "1.0.0"
  name                          = "core"
  environment                   = "qa"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  public_network_access_enabled = true
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  containers_list = [
    { name = "snapshot", access_type = "private" },
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
  source                  = "../../"
  name                    = "core"
  environment             = "dev"
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.resource_group_location
  private_dns_zone_id     = module.private_dns_zone.private_dns_zone_ids.azure_kubernetes
  private_cluster_enabled = true
  enable_backup           = true
  retention_rules         = []
  default_retention_rules = {
    default = {
      duration        = "P14D"
      data_store_type = "OperationalStore"
    }
  }
  backup_datasource_parameters = {
    included_namespaces              = ["default"]
    volume_snapshot_enabled          = true
    cluster_scoped_resources_enabled = true
  }
  backup_storage_account_name  = module.storage.storage_account_name
  backup_container_name        = keys(module.storage.containers)[0]
  snapshot_resource_group_name = module.snapshot_resource_group.resource_group_name
  snapshot_resource_group_id   = module.snapshot_resource_group.resource_group_id
  backup_storage_account_id    = module.storage.storage_account_id
  vnet_id                      = module.vnet.vnet_id
  default_node_pool_config = {
    enable_auto_scaling = false
    vnet_subnet_id      = module.subnet.subnet_ids.subnet1
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 32
  }
  key_vault_id               = module.vault.id
  admin_objects_ids          = [data.azurerm_client_config.current_client_config.object_id]
  microsoft_defender_enabled = false
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = module.log-analytics.workspace_id
}