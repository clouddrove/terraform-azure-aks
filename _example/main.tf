provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.0"

  name        = "app-13"
  environment = "test"
  label_order = ["environment", "name", ]
  location    = "North Europe"
}

module "vnet" {
  source  = "clouddrove/vnet/azure"
  version = "1.0.0"

  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.30.0.0/16"
  enable_ddos_pp      = false
}

module "subnet" {
  source               = "clouddrove/subnet/azure"
  version = "1.0.0"

  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

  #subnet
  default_name_subnet = true
  subnet_names        = ["subnet1", "subnet2"]
  subnet_prefixes     = ["10.30.1.0/24", "10.30.2.0/24"]

  # route_table
  enable_route_table = false
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "aks" {
  source      = "./../"
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  #networking
  service_cidr            = "10.0.0.0/16"
  docker_bridge_cidr      = "172.17.0.1/16"
  kubernetes_version      = "1.24.3"
  vnet_id                 = join("", module.vnet.vnet_id)
  nodes_subnet_id         = module.subnet.default_subnet_id[0]
  private_cluster_enabled = true
  enable_azure_policy     = true

  #azurerm_disk_encryption_set = false   ## Default Encryption at-rest with a platform-managed key
  #key_vault_id      = module.vault.id   

  default_node_pool = {
  max_pods              = 200
  os_disk_size_gb       = 64
  vm_size               = "Standard_B2s"
  count                 = 1
  enable_node_public_ip = false
}
  }
