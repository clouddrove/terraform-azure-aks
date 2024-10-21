
resource "azurerm_kubernetes_cluster" "aks" {
  count                             = var.enabled ? 1 : 0
  name                              = format("%s-aks", module.labels.id)
  location                          = local.location
  resource_group_name               = local.resource_group_name
  dns_prefix                        = replace(module.labels.id, "/[\\W_]/", "-")
  kubernetes_version                = var.kubernetes_version
  automatic_upgrade_channel         = var.automatic_upgrade_channel
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
  workload_identity_enabled         = var.workload_identity_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled

  default_node_pool {
    name                         = local.default_node_pool.agents_pool_name
    node_count                   = local.default_node_pool.count
    vm_size                      = local.default_node_pool.vm_size
    auto_scaling_enabled         = local.default_node_pool.auto_scaling_enabled
    min_count                    = local.default_node_pool.min_count
    max_count                    = local.default_node_pool.max_count
    max_pods                     = local.default_node_pool.max_pods
    os_disk_type                 = local.default_node_pool.os_disk_type
    os_disk_size_gb              = local.default_node_pool.os_disk_size_gb
    type                         = local.default_node_pool.type
    vnet_subnet_id               = local.default_node_pool.vnet_subnet_id
    host_encryption_enabled      = local.default_node_pool.host_encryption_enabled
    node_public_ip_enabled       = local.default_node_pool.node_public_ip_enabled
    fips_enabled                 = local.default_node_pool.fips_enabled
    node_labels                  = local.default_node_pool.node_labels
    only_critical_addons_enabled = local.default_node_pool.only_critical_addons_enabled
    orchestrator_version         = local.default_node_pool.orchestrator_version
    proximity_placement_group_id = local.default_node_pool.proximity_placement_group_id
    scale_down_mode              = local.default_node_pool.scale_down_mode
    snapshot_id                  = local.default_node_pool.snapshot_id
    tags                         = local.default_node_pool.tags
    temporary_name_for_rotation  = local.default_node_pool.temporary_name_for_rotation
    ultra_ssd_enabled            = local.default_node_pool.ultra_ssd_enabled
    zones                        = local.default_node_pool.zones
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

    dynamic "upgrade_settings" {
      for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]

      content {
        max_surge                     = var.agents_pool_max_surge
        drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
        node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
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


  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? ["http_proxy_config"] : []

    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = http_proxy_config.value.trusted_ca
    }
  }

  dynamic "confidential_computing" {
    for_each = var.confidential_computing == null ? [] : [var.confidential_computing]

    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
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
      revisions                        = var.service_mesh_profile.revisions
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
      blob_driver_enabled = var.storage_profile.blob_driver_enabled
      disk_driver_enabled = var.storage_profile.disk_driver_enabled
      # disk_driver_version         = var.storage_profile.disk_driver_version
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
      dns_zone_ids = var.web_app_routing.dns_zone_id
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


##-----------------------------------------------------------------------------
##Below resource will deploy private endpoint for AKS.
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep" {
  provider = azurerm.main_sub
  count    = var.enabled && var.enable_private_endpoint ? 1 : 0

  name                = format("%s-pe-akc", module.labels.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = module.labels.tags
  private_service_connection {
    name                           = format("%s-psc-akc", module.labels.id)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_kubernetes_cluster.aks[0].id
    subresource_names              = ["aks"]
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Data block to retreive private ip of private endpoint.
##-----------------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "private-ip" {
  provider            = azurerm.main_sub
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep[0].name
  resource_group_name = var.resource_group_name
}

##----------------------------------------------------------------------------- 
## Below resource will create private dns zone in your azure subscription. 
## Will be created only when there is no existing private dns zone and private endpoint is enabled. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "dnszone" {
  provider            = azurerm.main_sub
  count               = var.enabled && var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.kubernates.cluster.windows.net"
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in private dns.
## Vnet link will be created when there is no existing private dns zone or existing private dns zone is in same subscription.  
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link" {
  provider = azurerm.main_sub
  count    = var.enabled && var.enable_private_endpoint && var.diff_sub == false ? 1 : 0

  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-akc", module.labels.id) : format("%s-pdz-vnet-link-akc-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in existing private dns zone. 
## Vnet link will be created when existing private dns zone is in different subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-1" {
  provider              = azurerm.dns_sub
  count                 = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-akc", module.labels.id) : format("%s-pdz-vnet-link-akc-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in existing private dns zone. 
## Vnet link will be created when existing private dns zone is in different subscription. 
## This resource is deployed when more than 1 vnet link is required and module can be called again to do so without deploying other AKS resources. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-diff-subs" {
  provider = azurerm.dns_sub
  count    = var.enabled && var.multi_sub_vnet_link && var.existing_private_dns_zone != null ? 1 : 0

  name                  = format("%s-pdz-vnet-link-akc-1", module.labels.id)
  resource_group_name   = var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in private dns zone. 
## Below resource will be created when extra vnet link is required in dns zone in same subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "addon_vent_link" {
  provider = azurerm.main_sub
  count    = var.enabled && var.addon_vent_link ? 1 : 0

  name                  = format("%s-pdz-vnet-link-akc-addon", module.labels.id)
  resource_group_name   = var.addon_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone[0].name : var.existing_private_dns_zone
  virtual_network_id    = var.addon_virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create dns A record for private ip of private endpoint in private dns zone. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord" {
  provider = azurerm.main_sub
  count    = var.enabled && var.enable_private_endpoint && var.diff_sub == false ? 1 : 0

  name                = azurerm_kubernetes_cluster.aks[0].name
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip[0].private_service_connection[0].private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create dns A record for private ip of private endpoint in private dns zone. 
## This resource will be created when private dns is in different subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord-1" {
  provider = azurerm.dns_sub
  count    = var.enabled && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0


  name                = azurerm_kubernetes_cluster.aks[0].name
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip[0].private_service_connection[0].private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

locals {
  valid_rg_name         = var.existing_private_dns_zone == null ? var.resource_group_name : var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.enable_private_endpoint ? var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone[0].name : var.existing_private_dns_zone : null
}