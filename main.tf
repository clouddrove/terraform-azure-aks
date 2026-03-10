##-----------------------------------------------------------------------------
# Standard Tagging Module – Applies standard tags to all resources for traceability
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------
## AKS Cluster
##-----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  count                               = var.enable ? 1 : 0
  name                                = var.resource_position_prefix ? format("aks-%s", local.name) : format("%s-aks", local.name)
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  dns_prefix                          = var.dns_prefix
  kubernetes_version                  = var.kubernetes_version
  automatic_upgrade_channel           = var.automatic_channel_upgrade
  sku_tier                            = var.aks_sku_tier
  node_resource_group                 = var.node_resource_group == null ? (var.resource_position_prefix ? format("aks-node-rg-%s", local.name) : format("%s-aks-node-rg", local.name)) : var.node_resource_group
  disk_encryption_set_id              = var.key_vault_id != null ? azurerm_disk_encryption_set.main[0].id : null
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_enabled ? var.private_dns_zone_id : null
  azure_policy_enabled                = var.azure_policy_enabled
  edge_zone                           = var.edge_zone
  image_cleaner_enabled               = var.image_cleaner_enabled
  image_cleaner_interval_hours        = var.image_cleaner_interval_hours
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  local_account_disabled              = var.local_account_disabled
  dns_prefix_private_cluster          = var.dns_prefix == null ? var.dns_prefix_private_cluster : null
  cost_analysis_enabled               = var.cost_analysis_enabled
  custom_ca_trust_certificates_base64 = var.custom_ca_trust_certificates_base64
  http_application_routing_enabled    = var.http_application_routing_enabled
  ai_toolchain_operator_enabled       = var.ai_toolchain_operator_enabled
  node_os_upgrade_channel             = var.node_os_upgrade_channel
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  run_command_enabled                 = var.run_command_enabled
  support_plan                        = var.support_plan
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  dynamic "bootstrap_profile" {
    for_each = var.bootstrap_profile == null ? [] : [var.bootstrap_profile]
    content {
      artifact_source       = bootstrap_profile.value.artifact_source
      container_registry_id = bootstrap_profile.value.container_registry_id
    }
  }
  node_provisioning_profile {
    mode               = var.node_provisioning_mode
    default_node_pools = var.node_provisioning_default_node_pools
  }
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics == null ? [] : [var.monitor_metrics]

    content {
      annotations_allowed = monitor_metrics.value.annotations_allowed
      labels_allowed      = monitor_metrics.value.labels_allowed
    }
  }
  dynamic "maintenance_window" {
    for_each = var.maintenance_window == null ? [] : [var.maintenance_window]
    content {
      dynamic "allowed" {
        for_each = try(maintenance_window.value.allowed, [])
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = try(maintenance_window.value.not_allowed, [])
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }
  dynamic "default_node_pool" {
    for_each = [var.default_node_pool_config]
    content {
      name                          = default_node_pool.value.name
      node_count                    = default_node_pool.value.node_count
      vm_size                       = default_node_pool.value.vm_size
      auto_scaling_enabled          = default_node_pool.value.enable_auto_scaling
      host_encryption_enabled       = default_node_pool.value.enable_host_encryption
      max_count                     = default_node_pool.value.max_count
      min_count                     = default_node_pool.value.min_count
      max_pods                      = default_node_pool.value.max_pods
      node_labels                   = default_node_pool.value.node_labels
      node_public_ip_enabled        = default_node_pool.value.enable_node_public_ip
      only_critical_addons_enabled  = default_node_pool.value.only_critical_addons_enabled
      orchestrator_version          = default_node_pool.value.orchestrator_version
      os_disk_size_gb               = default_node_pool.value.os_disk_size_gb
      os_disk_type                  = default_node_pool.value.os_disk_type
      os_sku                        = default_node_pool.value.os_sku
      proximity_placement_group_id  = default_node_pool.value.proximity_placement_group_id
      type                          = default_node_pool.value.type
      vnet_subnet_id                = default_node_pool.value.vnet_subnet_id
      zones                         = default_node_pool.value.zones
      fips_enabled                  = default_node_pool.value.fips_enabled
      scale_down_mode               = default_node_pool.value.scale_down_mode
      snapshot_id                   = default_node_pool.value.snapshot_id
      temporary_name_for_rotation   = default_node_pool.value.temporary_name_for_rotation
      ultra_ssd_enabled             = default_node_pool.value.ultra_ssd_enabled
      pod_subnet_id                 = default_node_pool.value.pod_subnet_id
      tags                          = merge(module.labels.tags, default_node_pool.value.tags)
      capacity_reservation_group_id = default_node_pool.value.capacity_reservation_group_id
      gpu_driver                    = default_node_pool.value.gpu_driver
      gpu_instance                  = default_node_pool.value.gpu_instance
      host_group_id                 = default_node_pool.value.host_group_id
      kubelet_disk_type             = default_node_pool.value.kubelet_disk_type
      node_public_ip_prefix_id      = default_node_pool.value.node_public_ip_prefix_id
      workload_runtime              = default_node_pool.value.workload_runtime
      dynamic "node_network_profile" {
        for_each = var.node_network_profile == null ? [] : [var.node_network_profile]
        content {
          node_public_ip_tags            = node_network_profile.value.node_public_ip_tags
          application_security_group_ids = node_network_profile.value.application_security_group_ids
          dynamic "allowed_host_ports" {
            for_each = node_network_profile.value.allowed_host_ports
            content {
              port_start = allowed_host_ports.value.port_start
              port_end   = allowed_host_ports.value.port_end
              protocol   = allowed_host_ports.value.protocol
            }
          }
        }
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
      dynamic "upgrade_settings" {
        for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
        content {
          max_surge                     = var.agents_pool_max_surge
          drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
          node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
          undrainable_node_behavior     = var.agents_pool_undrainable_node_behavior
        }
      }
      dynamic "linux_os_config" {
        for_each = var.agents_pool_linux_os_configs
        content {
          swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
          transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
          transparent_huge_page        = linux_os_config.value.transparent_huge_page
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
    for_each = var.enable_http_proxy && var.http_proxy_config != null ? [var.http_proxy_config] : []
    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = try(http_proxy_config.value.trusted_ca, null)
    }
  }
  dynamic "confidential_computing" {
    for_each = var.confidential_computing == null ? [] : [var.confidential_computing]
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile == null ? [] : [var.api_server_access_profile]
    content {
      authorized_ip_ranges                = api_server_access_profile.value.authorized_ip_ranges
      subnet_id                           = api_server_access_profile.value.subnet_id
      virtual_network_integration_enabled = api_server_access_profile.value.virtual_network_integration_enabled
    }
  }
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile_enabled ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups                   = auto_scaler_profile.value.balance_similar_node_groups
      empty_bulk_delete_max                         = auto_scaler_profile.value.empty_bulk_delete_max
      expander                                      = auto_scaler_profile.value.expander
      max_graceful_termination_sec                  = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time                    = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                             = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage                        = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay                        = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add                    = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete                 = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure                = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded                           = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready                            = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold              = auto_scaler_profile.value.scale_down_utilization_threshold
      scan_interval                                 = auto_scaler_profile.value.scan_interval
      skip_nodes_with_local_storage                 = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods                   = auto_scaler_profile.value.skip_nodes_with_system_pods
      daemonset_eviction_for_empty_nodes_enabled    = auto_scaler_profile.value.daemonset_eviction_for_empty_nodes_enabled
      daemonset_eviction_for_occupied_nodes_enabled = auto_scaler_profile.value.daemonset_eviction_for_occupied_nodes_enabled
      ignore_daemonsets_utilization_enabled         = auto_scaler_profile.value.ignore_daemonsets_utilization_enabled
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
    for_each = var.service_mesh_profile == null ? [] : [var.service_mesh_profile]
    content {
      mode      = service_mesh_profile.value.mode
      revisions = lookup(service_mesh_profile.value, "revisions", [])
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
    type         = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.private_cluster_enabled && var.private_dns_zone_type == "Custom" ? [azurerm_user_assigned_identity.aks_user_assigned_identity[0].id] : []
  }
  dynamic "web_app_routing" {
    for_each = var.web_app_routing == null ? [] : ["web_app_routing"]
    content {
      dns_zone_ids             = var.web_app_routing.dns_zone_ids
      default_nginx_controller = var.web_app_routing.default_nginx_controller
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
    network_mode        = var.network_mode
    pod_cidrs           = var.pod_cidrs
    service_cidrs       = var.service_cidrs
    ip_versions         = var.ip_versions

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? [1] : []
      content {
        backend_pool_type           = var.load_balancer_profile_backend_pool_type
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
    dynamic "nat_gateway_profile" {
      for_each = var.nat_gateway_profile == null ? [] : [var.nat_gateway_profile]
      content {
        idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
      }
    }
    dynamic "advanced_networking" {
      for_each = var.advanced_networking == null ? [] : [var.advanced_networking]
      content {
        observability_enabled = advanced_networking.value.observability_enabled
        security_enabled      = advanced_networking.value.security_enabled
      }
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway == null ? [] : [var.ingress_application_gateway]

    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_id    = ingress_application_gateway.value.subnet_id
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
    }
  }
  dynamic "upgrade_override" {
    for_each = var.upgrade_override == null ? [] : [var.upgrade_override]

    content {
      force_upgrade_enabled = upgrade_override.value.force_upgrade_enabled
      effective_until       = upgrade_override.value.effective_until
    }
  }
  depends_on = [
    azurerm_role_assignment.aks_uai_private_dns_zone_contributor,
  ]
  tags = module.labels.tags
}

##-----------------------------------------------------------------------------
## Disk Encryption Set
##-----------------------------------------------------------------------------
resource "azurerm_disk_encryption_set" "main" {
  count               = var.enable && var.cmk_enabled ? 1 : 0
  name                = var.resource_position_prefix ? format("des-%s", local.name) : format("%s-des", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = var.key_vault_id != null ? azurerm_key_vault_key.main[0].id : null
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_extension" "main" {
  count                            = var.enable && var.enable_extensions ? 1 : 0
  name                             = var.resource_position_prefix ? format("aks-extension-%s", local.name) : format("%s-aks-extension", local.name)
  cluster_id                       = azurerm_kubernetes_cluster.main[0].id
  extension_type                   = var.extension_type
  configuration_settings           = var.configuration_settings
  configuration_protected_settings = var.configuration_protected_settings
  dynamic "plan" {
    for_each = var.enable_plan && var.plan_config != null ? [var.plan_config] : []
    content {
      name           = plan.value.name
      product        = plan.value.product
      publisher      = plan.value.publisher
      promotion_code = plan.value.promotion_code
      version        = plan.value.version
    }
  }
  release_train     = var.release_train
  release_namespace = var.release_namespace
  target_namespace  = var.target_namespace
  version           = var.extension_version
}

resource "azurerm_kubernetes_fleet_manager" "main" {
  count               = var.enable && var.enable_fleet_manager ? 1 : 0
  name                = var.resource_position_prefix ? format("aks-fleet-%s", local.name) : format("%s-aks-fleet", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = module.labels.tags
}

resource "azurerm_kubernetes_fleet_member" "main" {
  depends_on            = [azurerm_kubernetes_fleet_manager.main[0]]
  count                 = var.enable && var.enable_fleet_manager ? 1 : 0
  name                  = var.resource_position_prefix ? format("aks-fleet-member-%s", local.name) : format("%s-aks-fleet-member", local.name)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main[0].id
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.main[0].id
  group                 = var.fleet_member_group
}

resource "azurerm_kubernetes_fleet_update_run" "main" {
  depends_on                  = [azurerm_kubernetes_fleet_update_strategy.main[0], azurerm_kubernetes_fleet_member.main[0]]
  count                       = var.enable && var.enable_fleet_manager && var.enable_fleet_update_run ? 1 : 0
  name                        = var.resource_position_prefix ? format("aks-fleet-update-%s", local.name) : format("%s-aks-fleet-update", local.name)
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.main[0].id
  fleet_update_strategy_id    = var.enable_fleet_update_strategy ? azurerm_kubernetes_fleet_update_strategy.main[0].id : null
  managed_cluster_update {
    upgrade {
      type               = var.fleet_upgrade_type
      kubernetes_version = var.fleet_upgrade_kubernetes_version
    }
    dynamic "node_image_selection" {
      for_each = var.fleet_node_image_selection_type != null ? [1] : []
      content {
        type = var.fleet_node_image_selection_type
      }
    }
  }
  dynamic "stage" {
    for_each = var.enable_fleet_update_strategy ? [] : var.fleet_update_stages
    content {
      name = stage.value.name

      dynamic "group" {
        for_each = stage.value.groups
        content {
          name = group.value
        }
      }
      after_stage_wait_in_seconds = stage.value.after_stage_wait_in_seconds
    }
  }
}

resource "azurerm_kubernetes_fleet_update_strategy" "main" {
  count                       = var.enable && var.enable_fleet_manager && var.enable_fleet_update_strategy ? 1 : 0
  name                        = var.resource_position_prefix ? format("aks-fleet-strategy-%s", local.name) : format("%s-aks-fleet-strategy", local.name)
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.main[0].id
  dynamic "stage" {
    for_each = var.fleet_update_strategy_stages
    content {
      name = stage.value.name
      dynamic "group" {
        for_each = stage.value.groups
        content {
          name = group.value
        }
      }
      after_stage_wait_in_seconds = stage.value.after_stage_wait_in_seconds
    }
  }
}

resource "azurerm_kubernetes_flux_configuration" "main" {
  count      = var.enable && var.enable_flux_configuration ? 1 : 0
  name       = var.resource_position_prefix ? format("aks-flux-%s", local.name) : format("%s-aks-flux", local.name)
  cluster_id = azurerm_kubernetes_cluster.main[0].id
  namespace  = var.flux_namespace
  dynamic "kustomizations" {
    for_each = var.flux_kustomizations
    content {
      name                       = kustomizations.value.name
      path                       = kustomizations.value.path
      timeout_in_seconds         = kustomizations.value.timeout_in_seconds
      sync_interval_in_seconds   = kustomizations.value.sync_interval_in_seconds
      retry_interval_in_seconds  = kustomizations.value.retry_interval_in_seconds
      recreating_enabled         = kustomizations.value.recreating_enabled
      garbage_collection_enabled = kustomizations.value.garbage_collection_enabled
      depends_on                 = kustomizations.value.depends_on
      wait                       = kustomizations.value.wait
      dynamic "post_build" {
        for_each = kustomizations.value.post_build != null ? [kustomizations.value.post_build] : []
        content {
          substitute = try(post_build.value.substitute, null)

          dynamic "substitute_from" {
            for_each = try(post_build.value.substitute_from, [])
            content {
              kind     = substitute_from.value.kind
              name     = substitute_from.value.name
              optional = try(substitute_from.value.optional, null)
            }
          }
        }
      }
    }
  }
  dynamic "git_repository" {
    for_each = var.flux_git_repository != null ? [var.flux_git_repository] : []
    content {
      url                      = git_repository.value.url
      reference_type           = git_repository.value.reference_type
      reference_value          = git_repository.value.reference_value
      https_ca_cert_base64     = try(git_repository.value.https_ca_cert_base64, null)
      https_user               = try(git_repository.value.https_user, null)
      https_key_base64         = try(git_repository.value.https_key_base64, null)
      provider                 = try(git_repository.value.provider, null)
      local_auth_reference     = try(git_repository.value.local_auth_reference, null)
      ssh_private_key_base64   = try(git_repository.value.ssh_private_key_base64, null)
      ssh_known_hosts_base64   = try(git_repository.value.ssh_known_hosts_base64, null)
      sync_interval_in_seconds = try(git_repository.value.sync_interval_in_seconds, null)
      timeout_in_seconds       = try(git_repository.value.timeout_in_seconds, null)
    }
  }
  dynamic "bucket" {
    for_each = var.flux_bucket != null ? [var.flux_bucket] : []
    content {
      bucket_name              = bucket.value.bucket_name
      url                      = bucket.value.url
      access_key               = try(bucket.value.access_key, null)
      secret_key_base64        = try(bucket.value.secret_key_base64, null)
      tls_enabled              = try(bucket.value.tls_enabled, true)
      local_auth_reference     = try(bucket.value.local_auth_reference, null)
      sync_interval_in_seconds = try(bucket.value.sync_interval_in_seconds, null)
      timeout_in_seconds       = try(bucket.value.timeout_in_seconds, null)
    }
  }
  dynamic "blob_storage" {
    for_each = var.flux_blob_storage != null ? [var.flux_blob_storage] : []
    content {
      container_id             = blob_storage.value.container_id
      account_key              = try(blob_storage.value.account_key, null)
      local_auth_reference     = try(blob_storage.value.local_auth_reference, null)
      sas_token                = try(blob_storage.value.sas_token, null)
      sync_interval_in_seconds = try(blob_storage.value.sync_interval_in_seconds, null)
      timeout_in_seconds       = try(blob_storage.value.timeout_in_seconds, null)
      dynamic "managed_identity" {
        for_each = try(blob_storage.value.managed_identity, null) != null ? [blob_storage.value.managed_identity] : []
        content {
          client_id = managed_identity.value.client_id
        }
      }
      dynamic "service_principal" {
        for_each = try(blob_storage.value.service_principal, null) != null ? [blob_storage.value.service_principal] : []
        content {
          client_id                     = service_principal.value.client_id
          tenant_id                     = service_principal.value.tenant_id
          client_certificate_base64     = try(service_principal.value.client_certificate_base64, null)
          client_certificate_password   = try(service_principal.value.client_certificate_password, null)
          client_certificate_send_chain = try(service_principal.value.client_certificate_send_chain, null)
          client_secret                 = try(service_principal.value.client_secret, null)
        }
      }
    }
  }
  scope                             = var.flux_scope
  continuous_reconciliation_enabled = var.flux_continuous_reconciliation_enabled
  depends_on                        = [azurerm_kubernetes_cluster_extension.main]
}
