## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

## Vritual Network and Subnet Creation

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}


locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  default_node_pool = {
    agents_pool_name             = "agentpool"
    count                        = 1
    vm_size                      = "Standard_D2_v3"
    os_type                      = "Linux"
    enable_auto_scaling          = false
    enable_host_encryption       = false
    min_count                    = null
    max_count                    = null
    type                         = "VirtualMachineScaleSets"
    node_taints                  = null
    vnet_subnet_id               = var.nodes_subnet_id
    max_pods                     = 30
    os_disk_type                 = "Managed"
    os_disk_size_gb              = 128
    host_group_id                = null
    orchestrator_version         = null
    enable_node_public_ip        = false
    mode                         = "System"
    fips_enabled                 = null
    node_labels                  = null
    only_critical_addons_enabled = null
    orchestrator_version         = null
    proximity_placement_group_id = null
    scale_down_mode              = null
    snapshot_id                  = null
    tags                         = null
    temporary_name_for_rotation  = null
    ultra_ssd_enabled            = null
    zones                        = null
  }

  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_node_pool, ap)]
  nodes_pools               = [for ap in local.nodes_pools_with_defaults : ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)]
  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 128
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 256
  }
}

module "labels" {

  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

locals {
  private_dns_zone = var.private_dns_zone_type == "Custom" ? var.private_dns_zone_id : var.private_dns_zone_type
}