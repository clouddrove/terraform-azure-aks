##-----------------------------------------------------------------------------
## Additional Node Pools
##-----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each                      = var.enable ? var.node_pools : {}
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.main[0].id
  name                          = each.key
  vm_size                       = each.value.vm_size
  os_type                       = each.value.os_type
  os_disk_type                  = each.value.os_disk_type
  os_disk_size_gb               = each.value.os_disk_size_gb
  vnet_subnet_id                = each.value.vnet_subnet_id
  auto_scaling_enabled          = each.value.enable_auto_scaling
  host_encryption_enabled       = each.value.enable_host_encryption
  node_count                    = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count                     = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count                     = each.value.enable_auto_scaling ? each.value.max_count : null
  max_pods                      = each.value.max_pods
  node_public_ip_enabled        = each.value.enable_node_public_ip
  mode                          = each.value.mode
  orchestrator_version          = each.value.orchestrator_version
  node_taints                   = each.value.node_taints
  host_group_id                 = each.value.host_group_id
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  workload_runtime              = each.value.workload_runtime
  zones                         = each.value.zones
  fips_enabled                  = each.value.fips_enabled
  kubelet_disk_type             = each.value.kubelet_disk_type
  node_labels                   = each.value.node_labels
  pod_subnet_id                 = each.value.pod_subnet_id
  proximity_placement_group_id  = each.value.proximity_placement_group_id
  scale_down_mode               = each.value.scale_down_mode
  snapshot_id                   = each.value.snapshot_id
  spot_max_price                = each.value.spot_max_price
  tags                          = each.value.tags
  eviction_policy               = each.value.eviction_policy
  gpu_instance                  = each.value.gpu_instance
  os_sku                        = each.value.os_sku
  priority                      = each.value.priority
  temporary_name_for_rotation   = each.value.temporary_name_for_rotation
  ultra_ssd_enabled             = each.value.ultra_ssd_enabled
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
  dynamic "upgrade_settings" {
    for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
    content {
      max_surge                     = var.agents_pool_max_surge
      drain_timeout_in_minutes      = var.agents_pool_drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.agents_pool_node_soak_duration_in_minutes
    }
  }
  windows_profile {
    outbound_nat_enabled = var.outbound_nat_enabled
  }
}

##-----------------------------------------------------------------------------
## Key Vault Key for Encryption
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "main" {
  depends_on      = [azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enable && var.cmk_enabled ? 1 : 0
  name            = var.resource_position_prefix ? format("aks-encrypted-key-%s", local.name) : format("%s-aks-encrypted-key", local.name)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = var.cmk_key_type
  key_size        = var.cmk_key_size
  key_opts        = var.cmk_key_ops
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