resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  count                         = var.enabled ? length(local.nodes_pools) : 0
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks[0].id
  name                          = local.nodes_pools[count.index].name
  vm_size                       = local.nodes_pools[count.index].vm_size
  os_type                       = local.nodes_pools[count.index].os_type
  os_disk_type                  = local.nodes_pools[count.index].os_disk_type
  os_disk_size_gb               = local.nodes_pools[count.index].os_disk_size_gb
  vnet_subnet_id                = local.nodes_pools[count.index].vnet_subnet_id
  enable_auto_scaling           = local.nodes_pools[count.index].enable_auto_scaling
  enable_host_encryption        = local.nodes_pools[count.index].enable_host_encryption
  node_count                    = local.nodes_pools[count.index].count
  min_count                     = local.nodes_pools[count.index].min_count
  max_count                     = local.nodes_pools[count.index].max_count
  max_pods                      = local.nodes_pools[count.index].max_pods
  enable_node_public_ip         = local.nodes_pools[count.index].enable_node_public_ip
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
    for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]
    content {
      max_surge = var.agents_pool_max_surge
    }
  }

  windows_profile {
    outbound_nat_enabled = var.outbound_nat_enabled
  }
}
