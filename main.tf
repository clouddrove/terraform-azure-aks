## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

## Vritual Network and Subnet Creation

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}


locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  default_agent_profile = {
    name                          = "agentpool"
    count                         = 1
    vm_size                       = "Standard_D2_v3"
    os_type                       = "Linux"
    enable_auto_scaling           = false
    enable_host_encryption        = true
    min_count                     = null
    max_count                     = null
    type                          = "VirtualMachineScaleSets"
    node_taints                   = null
    vnet_subnet_id                = var.nodes_subnet_id
    max_pods                      = 30
    os_disk_type                  = "Managed"
    os_disk_size_gb               = 128
    host_group_id                 = null
    orchestrator_version          = null
    enable_node_public_ip         = false
    mode                          = "System"
    node_soak_duration_in_minutes = null
    max_surge                     = null
    drain_timeout_in_minutes      = null
  }

  default_node_pool         = merge(local.default_agent_profile, var.default_node_pool)
  nodes_pools_with_defaults = [for ap in var.nodes_pools : merge(local.default_agent_profile, ap)]
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

resource "azurerm_kubernetes_cluster" "aks" {
  count                             = var.enabled ? 1 : 0
  name                              = format("%s-aks", module.labels.id)
  location                          = local.location
  resource_group_name               = local.resource_group_name
  dns_prefix                        = replace(module.labels.id, "/[\\W_]/", "-")
  kubernetes_version                = var.kubernetes_version
  automatic_upgrade_channel         = var.automatic_channel_upgrade
  sku_tier                          = var.aks_sku_tier
  node_resource_group               = var.node_resource_group == null ? format("%s-aks-node-rg", module.labels.id) : var.node_resource_group
  disk_encryption_set_id            = var.key_vault_id != null ? azurerm_disk_encryption_set.main[0].id : null
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = var.private_cluster_enabled ? local.private_dns_zone : null
  http_application_routing_enabled  = var.enable_http_application_routing
  azure_policy_enabled              = var.azure_policy_enabled
  edge_zone                         = var.edge_zone
  image_cleaner_enabled             = var.image_cleaner_enabled
  image_cleaner_interval_hours      = var.image_cleaner_interval_hours
  role_based_access_control_enabled = var.role_based_access_control_enabled
  local_account_disabled            = var.local_account_disabled

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? ["default_node_pool_auto_scaled"] : []

    content {
      name                         = var.agents_pool_name
      vm_size                      = var.agents_size
      auto_scaling_enabled         = var.enable_auto_scaling
      host_encryption_enabled      = var.enable_host_encryption
      node_public_ip_enabled       = var.enable_node_public_ip
      fips_enabled                 = var.default_node_pool_fips_enabled
      max_count                    = var.agents_max_count
      max_pods                     = var.agents_max_pods
      min_count                    = var.agents_min_count
      node_labels                  = var.agents_labels
      only_critical_addons_enabled = var.only_critical_addons_enabled
      orchestrator_version         = var.orchestrator_version
      os_disk_size_gb              = var.os_disk_size_gb
      os_disk_type                 = var.os_disk_type
      os_sku                       = var.os_sku
      pod_subnet_id                = var.pod_subnet_id
      proximity_placement_group_id = var.agents_proximity_placement_group_id
      scale_down_mode              = var.scale_down_mode
      snapshot_id                  = var.snapshot_id
      tags                         = merge(var.tags, var.agents_tags)
      temporary_name_for_rotation  = var.temporary_name_for_rotation
      type                         = var.agents_type
      ultra_ssd_enabled            = var.ultra_ssd_enabled
      vnet_subnet_id               = var.vnet_subnet_id
      zones                        = var.agents_availability_zones

      node_network_profile {
        node_public_ip_tags = var.node_public_ip_tags
      }
      dynamic "kubelet_config" {
        for_each = var.agents_pool_kubelet_configs

        content {
          allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
          container_log_max_line    = kubelet_config.value.container_log_max_line
          container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
          cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
          cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
          cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
          image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
          image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
          pod_max_pid               = kubelet_config.value.pod_max_pid
          topology_manager_policy   = kubelet_config.value.topology_manager_policy
        }
      }
      dynamic "linux_os_config" {
        for_each = var.agents_pool_linux_os_configs

        content {
          swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
          transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
          transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled

          dynamic "sysctl_config" {
            for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs

            content {
              fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
              fs_file_max                        = sysctl_config.value.fs_file_max
              fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
              fs_nr_open                         = sysctl_config.value.fs_nr_open
              kernel_threads_max                 = sysctl_config.value.kernel_threads_max
              net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
              net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
              net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
              net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
              net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
              net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
              net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
              net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
              net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
              net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
              net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
              net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
              net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
              net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
              net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
              net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
              net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
              net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
              net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
              net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
              net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
              vm_max_map_count                   = sysctl_config.value.vm_max_map_count
              vm_swappiness                      = sysctl_config.value.vm_swappiness
              vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
            }
          }
        }
      }
    }
  }

  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux_enabled ? ["aci_connector_linux"] : []

    content {
      subnet_name = var.aci_connector_linux_subnet_name
    }
  }


  dynamic "ingress_application_gateway" {
    for_each = toset(var.ingress_application_gateway != null ? [var.ingress_application_gateway] : [])

    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }

  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["key_management_service"] : []

    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? ["key_vault_secrets_provider"] : []

    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity == null ? [] : [var.kubelet_identity]
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.enable_http_proxy ? [1] : []

    content {
      http_proxy  = var.http_proxy_config.http_proxy
      https_proxy = var.http_proxy_config.https_proxy
      no_proxy    = var.http_proxy_config.no_proxy
    }
  }

  dynamic "confidential_computing" {
    for_each = var.confidential_computing == null ? [] : [var.confidential_computing]

    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [1] : []

    content {
      authorized_ip_ranges = var.api_server_access_profile.authorized_ip_ranges
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile_enabled ? [var.auto_scaler_profile] : []

    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      empty_bulk_delete_max            = auto_scaler_profile.value.empty_bulk_delete_max
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      scan_interval                    = auto_scaler_profile.value.scan_interval
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade == null ? [] : [var.maintenance_window_auto_upgrade]
    content {
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      duration     = maintenance_window_auto_upgrade.value.duration
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      week_index   = maintenance_window_auto_upgrade.value.week_index
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      start_date   = maintenance_window_auto_upgrade.value.start_date

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed == null ? [] : maintenance_window_auto_upgrade.value.not_allowed
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os == null ? [] : [var.maintenance_window_node_os]
    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed == null ? [] : maintenance_window_node_os.value.not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control == null ? [] : var.role_based_access_control
    content {
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = !azure_active_directory_role_based_access_control.value.azure_rbac_enabled ? var.admin_group_id : null
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }
  }
  default_node_pool {
    name                        = local.default_node_pool.name
    node_count                  = local.default_node_pool.count
    vm_size                     = local.default_node_pool.vm_size
    auto_scaling_enabled        = local.default_node_pool.enable_auto_scaling
    min_count                   = local.default_node_pool.min_count
    max_count                   = local.default_node_pool.max_count
    max_pods                    = local.default_node_pool.max_pods
    os_disk_type                = local.default_node_pool.os_disk_type
    os_disk_size_gb             = local.default_node_pool.os_disk_size_gb
    type                        = local.default_node_pool.type
    vnet_subnet_id              = local.default_node_pool.vnet_subnet_id
    temporary_name_for_rotation = var.temporary_name_for_rotation
    host_encryption_enabled     = local.default_node_pool.enable_host_encryption
    dynamic "upgrade_settings" {
      for_each = local.default_node_pool.max_surge == null ? [] : ["upgrade_settings"]

      content {
        max_surge                     = local.default_node_pool.max_surge
        node_soak_duration_in_minutes = local.default_node_pool.node_soak_duration_in_minutes
        drain_timeout_in_minutes      = local.default_node_pool.drain_timeout_in_minutes
      }
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? ["microsoft_defender"] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = var.msi_auth_for_monitoring_enabled
    }
  }

  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile == null ? [] : ["service_mesh_profile"]
    content {
      mode                             = var.service_mesh_profile.mode
      external_ingress_gateway_enabled = var.service_mesh_profile.external_ingress_gateway_enabled
      internal_ingress_gateway_enabled = var.service_mesh_profile.internal_ingress_gateway_enabled
      revisions                        = var.service_mesh_profile.internal_ingress_gateway_enabled.revisions
    }
  }
  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []

    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
  dynamic "storage_profile" {
    for_each = var.storage_profile_enabled ? ["storage_profile"] : []

    content {
      blob_driver_enabled         = var.storage_profile.blob_driver_enabled
      disk_driver_enabled         = var.storage_profile.disk_driver_enabled
      file_driver_enabled         = var.storage_profile.file_driver_enabled
      snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
    }
  }

  identity {
    type = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? "UserAssigned" : "SystemAssigned"
  }

  dynamic "web_app_routing" {
    for_each = var.web_app_routing == null ? [] : ["web_app_routing"]

    content {
      dns_zone_ids = var.web_app_routing.dns_zone_ids
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile == null ? [] : [var.workload_autoscaler_profile]

    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }


  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? ["http_proxy_config"] : []

    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = http_proxy_config.value.trusted_ca
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []

    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license

      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []

        content {
          dns_server  = gmsa.value.dns_server
          root_domain = gmsa.value.root_domain
        }
      }
    }
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    network_data_plane  = var.network_data_plane
    dns_service_ip      = cidrhost(var.service_cidr, 10)
    service_cidr        = var.service_cidr
    load_balancer_sku   = var.load_balancer_sku
    network_plugin_mode = var.network_plugin_mode
    outbound_type       = var.outbound_type
    pod_cidr            = var.net_profile_pod_cidr


    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? [1] : []

      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
  ]
  tags = module.labels.tags
}
resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count                         = var.enabled ? length(local.nodes_pools) : 0
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks[0].id
  name                          = local.nodes_pools[count.index].name
  vm_size                       = local.nodes_pools[count.index].vm_size
  os_type                       = local.nodes_pools[count.index].os_type
  os_disk_type                  = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb               = local.nodes_pools[count.index].os_disk_size_gb
  vnet_subnet_id                = local.nodes_pools[count.index].vnet_subnet_id
  auto_scaling_enabled          = local.nodes_pools[count.index].enable_auto_scaling
  host_encryption_enabled       = local.nodes_pools[count.index].enable_host_encryption
  node_count                    = local.nodes_pools[count.index].count
  min_count                     = local.nodes_pools[count.index].min_count
  max_count                     = local.nodes_pools[count.index].max_count
  max_pods                      = local.nodes_pools[count.index].max_pods
  node_public_ip_enabled        = local.nodes_pools[count.index].enable_node_public_ip
  mode                          = local.nodes_pools[count.index].mode
  orchestrator_version          = local.nodes_pools[count.index].orchestrator_version
  node_taints                   = local.nodes_pools[count.index].node_taints
  host_group_id                 = local.nodes_pools[count.index].host_group_id
  capacity_reservation_group_id = var.capacity_reservation_group_id
  workload_runtime              = var.workload_runtime
  zones                         = var.agents_availability_zones

  dynamic "kubelet_config" {
    for_each = var.kubelet_config != null ? [var.kubelet_config] : []

    content {
      allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_line    = kubelet_config.value.container_log_max_line
      container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
      cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
      cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
      image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
      pod_max_pid               = kubelet_config.value.pod_max_pid
      topology_manager_policy   = kubelet_config.value.topology_manager_policy
    }
  }

  dynamic "linux_os_config" {
    for_each = var.agents_pool_linux_os_configs

    content {
      swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
      transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
      transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled

      dynamic "sysctl_config" {
        for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs

        content {
          fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
          fs_file_max                        = sysctl_config.value.fs_file_max
          fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
          fs_nr_open                         = sysctl_config.value.fs_nr_open
          kernel_threads_max                 = sysctl_config.value.kernel_threads_max
          net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
          net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
          net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
          net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
          net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
          net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
          net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
          net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
          net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = sysctl_config.value.vm_max_map_count
          vm_swappiness                      = sysctl_config.value.vm_swappiness
          vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
        }
      }
    }
  }
  dynamic "upgrade_settings" {
    for_each = local.nodes_pools[count.index].max_surge == null ? [] : ["upgrade_settings"]

    content {
      max_surge                     = local.nodes_pools[count.index].max_surge
      node_soak_duration_in_minutes = local.nodes_pools[count.index].node_soak_duration_in_minutes
      drain_timeout_in_minutes      = local.nodes_pools[count.index].drain_timeout_in_minutes
    }
  }

  windows_profile {
    outbound_nat_enabled = var.outbound_nat_enabled
  }
}

resource "azurerm_role_assignment" "aks_entra_id" {
  count                = var.enabled && var.role_based_access_control != null && try(var.role_based_access_control[0].azure_rbac_enabled, false) == true ? length(var.admin_group_id) : 0
  scope                = azurerm_kubernetes_cluster.aks[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.admin_group_id[count.index]
}

# Allow aks system indentiy access to encrpty disc
resource "azurerm_role_assignment" "aks_system_identity" {
  count                = var.enabled && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = azurerm_disk_encryption_set.main[0].id
  role_definition_name = "Reader"
}

# Allow aks system indentiy access to ACR
resource "azurerm_role_assignment" "aks_acr_access_principal_id" {
  count                = var.enabled && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "aks_acr_access_object_id" {
  count                = var.enabled && var.acr_enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}

# Allow user assigned identity to manage AKS items in MC_xxx RG
resource "azurerm_role_assignment" "aks_user_assigned" {
  count                = var.enabled ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks[0].node_resource_group)
  role_definition_name = "Network Contributor"
}

resource "azurerm_user_assigned_identity" "aks_user_assigned_identity" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  name                = format("%s-aks-mid", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_role_assignment" "aks_uai_private_dns_zone_contributor" {
  count = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_uai_vnet_network_contributor" {
  count                = var.enabled && var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? 1 : 0
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_secrets_provider" {
  count                = var.enabled && var.key_vault_secrets_provider_enabled ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_kubernetes_cluster.aks[0].key_vault_secrets_provider[0].secret_identity[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enabled && var.cmk_enabled ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

resource "azurerm_key_vault_key" "example" {
  depends_on      = [azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_enabled ? 1 : 0
  name            = format("%s-aks-encrypted-key", module.labels.id)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

resource "azurerm_disk_encryption_set" "main" {
  count               = var.enabled && var.cmk_enabled ? 1 : 0
  name                = format("%s-aks-dsk-encrpted", module.labels.id)
  resource_group_name = local.resource_group_name
  location            = local.location
  key_vault_key_id    = var.key_vault_id != "" ? azurerm_key_vault_key.example[0].id : null

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "azurerm_disk_encryption_set_key_vault_access" {
  count                = var.enabled && var.cmk_enabled ? 1 : 0
  principal_id         = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_key_vault_access_policy" "main" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = azurerm_disk_encryption_set.main[0].identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.main[0].identity[0].principal_id
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
  certificate_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "key_vault" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

resource "azurerm_key_vault_access_policy" "kubelet_identity" {
  count = var.enabled && var.cmk_enabled ? 1 : 0

  key_vault_id = var.key_vault_id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id

  key_permissions         = ["Get"]
  certificate_permissions = ["Get"]
  secret_permissions      = ["Get"]
}

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
    ignore_changes = [target_resource_id, log_analytics_destination_type]
  }
}

data "azurerm_resources" "aks_pip" {
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count      = var.enabled && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/publicIPAddresses"
  required_tags = {
    Environment = var.environment
    Name        = module.labels.id
    Repository  = var.repository
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
    ignore_changes = [target_resource_id, log_analytics_destination_type]
  }
}

data "azurerm_resources" "aks_nsg" {
  depends_on = [data.azurerm_resources.aks_nsg, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count      = var.enabled && var.diagnostic_setting_enable ? 1 : 0
  type       = "Microsoft.Network/networkSecurityGroups"
  required_tags = {
    Environment = var.environment
    Name        = module.labels.id
    Repository  = var.repository
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
    ignore_changes = [target_resource_id, log_analytics_destination_type]
  }
}

data "azurerm_resources" "aks_nic" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  count      = var.enabled && var.diagnostic_setting_enable && var.private_cluster_enabled == true ? 1 : 0
  type       = "Microsoft.Network/networkInterfaces"
  required_tags = {
    Environment = var.environment
    Name        = module.labels.id
    Repository  = var.repository
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
    ignore_changes = [log_analytics_destination_type, log_analytics_destination_type]
  }
}

## AKS user authentication with Azure Rbac. 
resource "azurerm_role_assignment" "example" {
  for_each = var.enabled && var.aks_user_auth_role != null ? { for k in var.aks_user_auth_role : k.principal_id => k } : null
  # scope                = 
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}