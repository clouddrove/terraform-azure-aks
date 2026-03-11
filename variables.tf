##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = null
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "location" {
  type        = string
  default     = null
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-aks"
  description = "Terraform current module repo"

  validation {
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

##-----------------------------------------------------------------------------
## Global Variables
##-----------------------------------------------------------------------------
variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "A container that holds related resources for an Azure solution"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.33"
  description = "Version of Kubernetes to deploy"
}

variable "node_resource_group" {
  type        = string
  default     = null
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "Edge Zone for the AKS cluster."
}

##-----------------------------------------------------------------------------
## Cluster Configuration
##-----------------------------------------------------------------------------
variable "aks_sku_tier" {
  type        = string
  default     = "Standard"
  description = "AKS SKU tier. Possible values are Free or Paid"
}

variable "dns_prefix" {
  type        = string
  default     = "azure-kubernates"
  description = "DNS prefix for the AKS cluster. If null, will be auto-generated from cluster name"
}

variable "dns_prefix_private_cluster" {
  type        = string
  default     = null
  description = "DNS prefix for private AKS cluster. Only used when dns_prefix is null and private_cluster_enabled is true"
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = null
  description = "Auto-upgrade channel: `patch`, `rapid`, `node-image`, `stable`."
}

variable "local_account_disabled" {
  type        = bool
  default     = false
  description = "Disable local account?"
}

variable "cost_analysis_enabled" {
  type        = bool
  default     = false
  description = "Enable cost analysis for the AKS cluster to track and optimize spending"
}

variable "custom_ca_trust_certificates_base64" {
  type        = list(string)
  default     = []
  description = "List of custom Certificate Authority (CA) certificates in base64 format to be trusted by the cluster"
}

variable "http_application_routing_enabled" {
  type        = bool
  default     = false
  description = "Enable HTTP application routing addon (deprecated, not recommended for production)"
}

variable "ai_toolchain_operator_enabled" {
  type        = bool
  default     = false
  description = "Enable AI Toolchain Operator for running AI/ML workloads on the cluster"
}

variable "node_os_upgrade_channel" {
  type        = string
  default     = "NodeImage"
  description = "The upgrade channel for node OS image updates. Valid values: Unmanaged, SecurityPatch, NodeImage, None"
  validation {
    condition     = can(regex("^(Unmanaged|SecurityPatch|NodeImage|None)$", var.node_os_upgrade_channel))
    error_message = "node_os_upgrade_channel must be one of: Unmanaged, SecurityPatch, NodeImage, None"
  }
}

variable "oidc_issuer_enabled" {
  type        = bool
  default     = false
  description = "Enable OIDC issuer for workload identity federation"
}

variable "workload_identity_enabled" {
  type        = bool
  default     = false
  description = "Enable workload identity for Azure AD pod-managed identity integration"
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  default     = false
  description = "Enable public FQDN for private cluster to allow access from public networks"
}

variable "run_command_enabled" {
  type        = bool
  default     = true
  description = "Enable run command to execute commands on the cluster without direct network connectivity"
}

variable "support_plan" {
  type        = string
  default     = "KubernetesOfficial"
  description = "The support plan for the AKS cluster. Valid values: KubernetesOfficial, AKSLongTermSupport"
  validation {
    condition     = can(regex("^(KubernetesOfficial|AKSLongTermSupport)$", var.support_plan))
    error_message = "support_plan must be either KubernetesOfficial or AKSLongTermSupport"
  }
}

variable "open_service_mesh_enabled" {
  type        = bool
  default     = false
  description = "Enable Open Service Mesh (OSM) addon for service mesh capabilities"
}

variable "bootstrap_profile" {
  type = object({
    artifact_source       = string
    container_registry_id = string
  })
  default     = null
  description = "Bootstrap profile configuration for the AKS cluster to specify artifact source and container registry"
}

variable "monitor_metrics" {
  type = object({
    annotations_allowed = list(string)
    labels_allowed      = list(string)
  })
  default     = null
  description = "Configuration for Prometheus metrics collection, specifying allowed annotations and labels to scrape"
}

variable "maintenance_window" {
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })))
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default     = null
  description = "Maintenance window configuration for the AKS cluster with allowed and not_allowed time periods"
}

variable "node_network_profile" {
  type = object({
    node_public_ip_tags            = map(string)
    application_security_group_ids = list(string)
    allowed_host_ports = list(object({
      port_start = number
      port_end   = number
      protocol   = string
    }))
  })
  default     = null
  description = "Node network profile configuration for the node pool including public IP tags, security groups, and allowed host ports"
}

##-----------------------------------------------------------------------------
## Network Configuration
##-----------------------------------------------------------------------------
variable "network_plugin" {
  type        = string
  default     = "azure"
  description = "Network plugin for networking."
}

variable "network_policy" {
  type        = string
  default     = "azure"
  description = "Network policy to be used with Azure CNI (`calico` or `azure`)."
}

variable "network_plugin_mode" {
  type        = string
  default     = null
  description = "Network plugin mode (e.g., `Overlay`)."
}

variable "network_data_plane" {
  type        = string
  default     = null
  description = "eBPF data plane (e.g., `cilium`)."
}

variable "service_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR used by kubernetes services."
}

variable "net_profile_pod_cidr" {
  type        = string
  default     = null
  description = "Pod CIDR (kubenet only)."
}

variable "outbound_type" {
  type        = string
  default     = "loadBalancer"
  description = "Outbound routing method: `loadBalancer` or `userDefinedRouting`."
}

variable "vnet_id" {
  type        = string
  default     = null
  description = "VNet id that AKS MSI should be Network Contributor on (private cluster)."
}

variable "outbound_nat_enabled" {
  type        = bool
  default     = true
  description = "Windows nodes outbound NAT enabled."
}

##-----------------------------------------------------------------------------
## Private Cluster Configuration
##-----------------------------------------------------------------------------
variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "Configure AKS as a Private Cluster"
}

variable "private_dns_zone_type" {
  type        = string
  default     = "Custom"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom": Bring your own Private DNS Zone and pass its id via `private_dns_zone_id`.
- "System": AKS manages the zone in the Node Resource Group.
- "None": Bring your own DNS server/resolution.
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is Custom"
}

##-----------------------------------------------------------------------------
## API Server Access Configuration
##-----------------------------------------------------------------------------
variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges                = optional(list(string))
    subnet_id                           = optional(string)
    virtual_network_integration_enabled = optional(bool)
  })
  default     = null
  description = "Control public/private API server exposure"
}

##-----------------------------------------------------------------------------
## Load Balancer Configuration
##-----------------------------------------------------------------------------
variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "Load Balancer SKU: `basic` or `standard`."
  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}

variable "load_balancer_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable a load_balancer_profile block (requires `standard` SKU)."
  nullable    = false
}

variable "load_balancer_profile_idle_timeout_in_minutes" {
  type        = number
  default     = 30
  description = "Outbound flow idle timeout in minutes for the cluster load balancer (4–120)."
}

variable "load_balancer_profile_managed_outbound_ip_count" {
  type        = number
  default     = null
  description = "Count of managed outbound IPs (1–100)."
}

variable "load_balancer_profile_managed_outbound_ipv6_count" {
  type        = number
  default     = null
  description = "Count of managed outbound IPv6 IPs (requires dual-stack)."
}

variable "load_balancer_profile_outbound_ip_address_ids" {
  type        = set(string)
  default     = null
  description = "Public IP IDs for outbound communication."
}

variable "load_balancer_profile_outbound_ip_prefix_ids" {
  type        = set(string)
  default     = null
  description = "Public IP Prefix IDs for outbound communication."
}

variable "load_balancer_profile_outbound_ports_allocated" {
  type        = number
  default     = 0
  description = "SNAT ports per VM (0–64000)."
}

variable "load_balancer_profile_backend_pool_type" {
  type        = string
  default     = null
  description = "SNAT ports per VM (0–64000)."
}

##-----------------------------------------------------------------------------
## Default Node Pool Configuration
##-----------------------------------------------------------------------------
variable "default_node_pool_config" {
  type = object({
    name                          = optional(string, "agentpool")
    node_count                    = optional(number, 1)
    vm_size                       = optional(string, "Standard_D2s_v3")
    enable_auto_scaling           = optional(bool, false)
    enable_host_encryption        = optional(bool, true)
    min_count                     = optional(number, null)
    max_count                     = optional(number, null)
    type                          = optional(string, "VirtualMachineScaleSets")
    vnet_subnet_id                = string
    max_pods                      = optional(number, 50)
    os_disk_type                  = optional(string, "Managed")
    os_disk_size_gb               = optional(number, 128)
    os_sku                        = optional(string, null)
    orchestrator_version          = optional(string, null)
    enable_node_public_ip         = optional(bool, false)
    zones                         = optional(list(string), null)
    node_labels                   = optional(map(string), null)
    only_critical_addons_enabled  = optional(bool, true)
    fips_enabled                  = optional(bool, null)
    proximity_placement_group_id  = optional(string, null)
    scale_down_mode               = optional(string, null)
    snapshot_id                   = optional(string, null)
    temporary_name_for_rotation   = optional(string, null)
    ultra_ssd_enabled             = optional(bool, null)
    pod_subnet_id                 = optional(string, null)
    tags                          = optional(map(string), null)
    capacity_reservation_group_id = optional(string, null)
    gpu_driver                    = optional(string, null)
    gpu_instance                  = optional(string, null)
    host_group_id                 = optional(string, null)
    kubelet_disk_type             = optional(string, null)
    node_public_ip_prefix_id      = optional(string, null)
    workload_runtime              = optional(string, null)
  })
  description = "Configuration for the default system node pool"
}

variable "agents_pool_max_surge" {
  type        = string
  default     = "10%"
  description = "The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade."
}

variable "agents_pool_node_soak_duration_in_minutes" {
  type        = number
  default     = 0
  description = "(Optional) The amount of time in minutes to wait after draining a node and before reimaging and moving on to next node. Defaults to 0."
}

variable "agents_pool_drain_timeout_in_minutes" {
  type        = number
  default     = null
  description = "(Optional) The amount of time in minutes to wait on eviction of pods and graceful termination per node. This eviction wait time honors waiting on pod disruption budgets. If this time is exceeded, the upgrade fails. Unsetting this after configuring it will force a new resource to be created."
}

variable "agents_pool_undrainable_node_behavior" {
  type        = string
  default     = null
  description = "Behavior for undrainable nodes during upgrade. Possible values are Schedule and Cordon"
}

##-----------------------------------------------------------------------------
## Additional Node Pools Configuration
##-----------------------------------------------------------------------------
variable "node_pools" {
  type = map(object({
    vm_size                       = optional(string, "Standard_D2s_v3")
    os_type                       = optional(string, "Linux")
    os_disk_type                  = optional(string, null)
    os_disk_size_gb               = optional(number, null)
    vnet_subnet_id                = string
    enable_auto_scaling           = optional(bool, false)
    enable_host_encryption        = optional(bool, true)
    eviction_policy               = optional(string, null)
    gpu_instance                  = optional(string)
    os_sku                        = optional(string, null)
    priority                      = optional(string, null)
    node_count                    = optional(number, null)
    min_count                     = optional(number, null)
    max_count                     = optional(number, null)
    max_pods                      = optional(number, 50)
    enable_node_public_ip         = optional(bool, null)
    mode                          = optional(string, "User")
    orchestrator_version          = optional(string, null)
    node_taints                   = optional(list(string), null)
    host_group_id                 = optional(string, null)
    zones                         = optional(list(string), null)
    node_soak_duration_in_minutes = optional(number, null)
    drain_timeout_in_minutes      = optional(number, null)
    capacity_reservation_group_id = optional(string, null)
    workload_runtime              = optional(string, null)
    fips_enabled                  = optional(bool, null)
    kubelet_disk_type             = optional(string, null)
    node_labels                   = optional(map(string), null)
    pod_subnet_id                 = optional(string, null)
    proximity_placement_group_id  = optional(string, null)
    temporary_name_for_rotation   = optional(string, null)
    scale_down_mode               = optional(string, null)
    snapshot_id                   = optional(string, null)
    spot_max_price                = optional(number, null)
    tags                          = optional(map(string), null)
    ultra_ssd_enabled             = optional(bool, null)
  }))
  default     = {}
  description = "Map of additional node pools"
}

##-----------------------------------------------------------------------------
## Node Pool Advanced Configuration
##-----------------------------------------------------------------------------
variable "kubelet_config" {
  type = object({
    allowed_unsafe_sysctls    = optional(list(string))
    container_log_max_line    = optional(number)
    container_log_max_size_mb = optional(string)
    cpu_cfs_quota_enabled     = optional(bool)
    cpu_cfs_quota_period      = optional(string)
    cpu_manager_policy        = optional(string)
    image_gc_high_threshold   = optional(number)
    image_gc_low_threshold    = optional(number)
    pod_max_pid               = optional(number)
    topology_manager_policy   = optional(string)
  })
  default     = null
  description = "Kubelet configuration options."
}

variable "agents_pool_kubelet_configs" {
  type = list(object({
    cpu_manager_policy        = optional(string)
    cpu_cfs_quota_enabled     = optional(bool, true)
    cpu_cfs_quota_period      = optional(string)
    image_gc_high_threshold   = optional(number)
    image_gc_low_threshold    = optional(number)
    topology_manager_policy   = optional(string)
    allowed_unsafe_sysctls    = optional(set(string))
    container_log_max_size_mb = optional(number)
    container_log_max_line    = optional(number)
    pod_max_pid               = optional(number)
  }))
  default     = []
  description = "Per-pool kubelet configs (advanced)."
}

variable "agents_pool_linux_os_configs" {
  type = list(object({
    sysctl_configs = optional(list(object({
      fs_aio_max_nr                      = optional(number)
      fs_file_max                        = optional(number)
      fs_inotify_max_user_watches        = optional(number)
      fs_nr_open                         = optional(number)
      kernel_threads_max                 = optional(number)
      net_core_netdev_max_backlog        = optional(number)
      net_core_optmem_max                = optional(number)
      net_core_rmem_default              = optional(number)
      net_core_rmem_max                  = optional(number)
      net_core_somaxconn                 = optional(number)
      net_core_wmem_default              = optional(number)
      net_core_wmem_max                  = optional(number)
      net_ipv4_ip_local_port_range_min   = optional(number)
      net_ipv4_ip_local_port_range_max   = optional(number)
      net_ipv4_neigh_default_gc_thresh1  = optional(number)
      net_ipv4_neigh_default_gc_thresh2  = optional(number)
      net_ipv4_neigh_default_gc_thresh3  = optional(number)
      net_ipv4_tcp_fin_timeout           = optional(number)
      net_ipv4_tcp_keepalive_intvl       = optional(number)
      net_ipv4_tcp_keepalive_probes      = optional(number)
      net_ipv4_tcp_keepalive_time        = optional(number)
      net_ipv4_tcp_max_syn_backlog       = optional(number)
      net_ipv4_tcp_max_tw_buckets        = optional(number)
      net_ipv4_tcp_tw_reuse              = optional(bool)
      net_netfilter_nf_conntrack_buckets = optional(number)
      net_netfilter_nf_conntrack_max     = optional(number)
      vm_max_map_count                   = optional(number)
      vm_swappiness                      = optional(number)
      vm_vfs_cache_pressure              = optional(number)
    })), [])
    transparent_huge_page_enabled = optional(string)
    transparent_huge_page_defrag  = optional(string)
    swap_file_size_mb             = optional(number)
  }))
  default     = []
  description = <<-EOT
  list(object({
    sysctl_configs = optional(list(object({
      fs_aio_max_nr                      = (Optional) The sysctl setting fs.aio-max-nr. Must be between `65536` and `6553500`. Changing this forces a new resource to be created.
      fs_file_max                        = (Optional) The sysctl setting fs.file-max. Must be between `8192` and `12000500`. Changing this forces a new resource to be created.
      fs_inotify_max_user_watches        = (Optional) The sysctl setting fs.inotify.max_user_watches. Must be between `781250` and `2097152`. Changing this forces a new resource to be created.
      fs_nr_open                         = (Optional) The sysctl setting fs.nr_open. Must be between `8192` and `20000500`. Changing this forces a new resource to be created.
      kernel_threads_max                 = (Optional) The sysctl setting kernel.threads-max. Must be between `20` and `513785`. Changing this forces a new resource to be created.
      net_core_netdev_max_backlog        = (Optional) The sysctl setting net.core.netdev_max_backlog. Must be between `1000` and `3240000`. Changing this forces a new resource to be created.
      net_core_optmem_max                = (Optional) The sysctl setting net.core.optmem_max. Must be between `20480` and `4194304`. Changing this forces a new resource to be created.
      net_core_rmem_default              = (Optional) The sysctl setting net.core.rmem_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_rmem_max                  = (Optional) The sysctl setting net.core.rmem_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_somaxconn                 = (Optional) The sysctl setting net.core.somaxconn. Must be between `4096` and `3240000`. Changing this forces a new resource to be created.
      net_core_wmem_default              = (Optional) The sysctl setting net.core.wmem_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_core_wmem_max                  = (Optional) The sysctl setting net.core.wmem_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.
      net_ipv4_ip_local_port_range_min   = (Optional) The sysctl setting net.ipv4.ip_local_port_range max value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.
      net_ipv4_ip_local_port_range_max   = (Optional) The sysctl setting net.ipv4.ip_local_port_range min value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh1  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh1. Must be between `128` and `80000`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh2  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh2. Must be between `512` and `90000`. Changing this forces a new resource to be created.
      net_ipv4_neigh_default_gc_thresh3  = (Optional) The sysctl setting net.ipv4.neigh.default.gc_thresh3. Must be between `1024` and `100000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_fin_timeout           = (Optional) The sysctl setting net.ipv4.tcp_fin_timeout. Must be between `5` and `120`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_intvl       = (Optional) The sysctl setting net.ipv4.tcp_keepalive_intvl. Must be between `10` and `75`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_probes      = (Optional) The sysctl setting net.ipv4.tcp_keepalive_probes. Must be between `1` and `15`. Changing this forces a new resource to be created.
      net_ipv4_tcp_keepalive_time        = (Optional) The sysctl setting net.ipv4.tcp_keepalive_time. Must be between `30` and `432000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_max_syn_backlog       = (Optional) The sysctl setting net.ipv4.tcp_max_syn_backlog. Must be between `128` and `3240000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_max_tw_buckets        = (Optional) The sysctl setting net.ipv4.tcp_max_tw_buckets. Must be between `8000` and `1440000`. Changing this forces a new resource to be created.
      net_ipv4_tcp_tw_reuse              = (Optional) The sysctl setting net.ipv4.tcp_tw_reuse. Changing this forces a new resource to be created.
      net_netfilter_nf_conntrack_buckets = (Optional) The sysctl setting net.netfilter.nf_conntrack_buckets. Must be between `65536` and `147456`. Changing this forces a new resource to be created.
      net_netfilter_nf_conntrack_max     = (Optional) The sysctl setting net.netfilter.nf_conntrack_max. Must be between `131072` and `1048576`. Changing this forces a new resource to be created.
      vm_max_map_count                   = (Optional) The sysctl setting vm.max_map_count. Must be between `65530` and `262144`. Changing this forces a new resource to be created.
      vm_swappiness                      = (Optional) The sysctl setting vm.swappiness. Must be between `0` and `100`. Changing this forces a new resource to be created.
      vm_vfs_cache_pressure              = (Optional) The sysctl setting vm.vfs_cache_pressure. Must be between `0` and `100`. Changing this forces a new resource to be created.
    })), [])
    transparent_huge_page_enabled = (Optional) Specifies the Transparent Huge Page enabled configuration. Possible values are `always`, `madvise` and `never`. Changing this forces a new resource to be created.
    transparent_huge_page_defrag  = (Optional) specifies the defrag configuration for Transparent Huge Page. Possible values are `always`, `defer`, `defer+madvise`, `madvise` and `never`. Changing this forces a new resource to be created.
    swap_file_size_mb             = (Optional) Specifies the size of the swap file on each node in MB. Changing this forces a new resource to be created.
  }))
EOT
  nullable    = false
}

##-----------------------------------------------------------------------------
## Auto Scaler Configuration
##-----------------------------------------------------------------------------
variable "auto_scaler_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable configuring the cluster autoscaler profile"
  nullable    = false
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups                   = optional(bool)
    empty_bulk_delete_max                         = optional(number)
    expander                                      = optional(string)
    max_graceful_termination_sec                  = optional(string)
    max_node_provisioning_time                    = optional(string)
    max_unready_nodes                             = optional(number)
    max_unready_percentage                        = optional(number)
    new_pod_scale_up_delay                        = optional(string)
    scale_down_delay_after_add                    = optional(string)
    scale_down_delay_after_delete                 = optional(string)
    scale_down_delay_after_failure                = optional(string)
    scale_down_unneeded                           = optional(string)
    scale_down_unready                            = optional(string)
    scale_down_utilization_threshold              = optional(string)
    scan_interval                                 = optional(string)
    skip_nodes_with_local_storage                 = optional(bool)
    skip_nodes_with_system_pods                   = optional(bool)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)
    ignore_daemonsets_utilization_enabled         = optional(bool)
  })
  default = {
    balance_similar_node_groups      = false
    empty_bulk_delete_max            = 10
    expander                         = "random"
    max_graceful_termination_sec     = "600"
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = null
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
    scan_interval                    = "10s"
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }
  description = "Cluster autoscaler profile configuration"
}

variable "node_provisioning_mode" {
  type        = string
  default     = "Manual"
  description = "Provisioning mode for AKS node pools"
}

variable "node_provisioning_default_node_pools" {
  type        = string
  default     = "Auto"
  description = "Whether default node pools should be provisioned automatically"
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool, false)
    vertical_pod_autoscaler_enabled = optional(bool, false)
  })
  default     = null
  description = "Workload autoscaler profile (KEDA/VPA)."
}

##-----------------------------------------------------------------------------
## Linux Profile Configuration
##-----------------------------------------------------------------------------
variable "linux_profile" {
  type = object({
    username = string,
    ssh_key  = string
  })
  default     = null
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
}

##-----------------------------------------------------------------------------
## Windows Profile Configuration
##-----------------------------------------------------------------------------
variable "windows_profile" {
  type = object({
    admin_username = string
    admin_password = optional(string)
    license        = optional(string)
    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }))
  })
  default     = null
  description = "Windows profile configuration"
}

##-----------------------------------------------------------------------------
## Identity Configuration
##-----------------------------------------------------------------------------
variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = "User-assigned identity for Kubelets (optional)."
}

variable "client_id" {
  type        = string
  default     = ""
  description = "Service Principal Client ID"
  nullable    = false
}

variable "client_secret" {
  type        = string
  default     = ""
  description = "Service Principal Client Secret"
  nullable    = false
}

##-----------------------------------------------------------------------------
## RBAC and Access Control
##-----------------------------------------------------------------------------
variable "role_based_access_control_enabled" {
  type        = bool
  default     = true
  description = "Enable Role-Based Access Control (RBAC) for the AKS cluster"
}

variable "role_based_access_control" {
  type = list(object({
    managed            = bool
    tenant_id          = optional(string)
    azure_rbac_enabled = bool
  }))
  default     = null
  description = "RBAC configuration block specifying managed AAD integration, tenant ID, and Azure RBAC enablement"
}

variable "admin_group_id" {
  type        = list(string)
  default     = null
  description = "List of Azure AD group object IDs that will have admin access to the AKS cluster"
}

variable "admin_objects_ids" {
  type        = list(string)
  default     = null
  description = "List of Azure AD object IDs (users or service principals) that will have admin access to the AKS cluster"
}

variable "user_aks_roles" {
  type = map(object({
    role_definition = string
    principal_ids   = list(string)
  }))
  default     = null
  description = "Map of role definitions to their respective admin group IDs"
}

variable "aks_user_auth_role" {
  type        = any
  default     = []
  description = "Group/User role-based access to AKS"
}

##-----------------------------------------------------------------------------
## ACR Integration
##-----------------------------------------------------------------------------
variable "acr_enabled" {
  type        = bool
  default     = false
  description = "Enable ACR access for AKS"
}

variable "acr_id" {
  type        = string
  default     = null
  description = "ACR resource ID to grant access to AKS"
}

##-----------------------------------------------------------------------------
## Add-ons Configuration
##-----------------------------------------------------------------------------
variable "azure_policy_enabled" {
  type        = bool
  default     = true
  description = "Enable Azure Policy Addon."
}

variable "microsoft_defender_enabled" {
  type        = bool
  default     = false
  description = "Enable Microsoft Defender add-on."
}

variable "oms_agent_enabled" {
  type        = bool
  default     = false
  description = "Enable Log Analytics (OMS agent) add-on."
}

variable "aci_connector_linux_enabled" {
  type        = bool
  default     = false
  description = "Enable Virtual Node pool"
}

variable "aci_connector_linux_subnet_name" {
  type        = string
  default     = null
  description = "aci_connector_linux subnet name"
}

##-----------------------------------------------------------------------------
## Service Mesh Configuration
##-----------------------------------------------------------------------------
variable "service_mesh_profile" {
  type = object({
    mode                             = string
    internal_ingress_gateway_enabled = optional(bool, true)
    external_ingress_gateway_enabled = optional(bool, true)
  })
  default     = null
  description = "Istio service mesh configuration."
}

variable "web_app_routing" {
  type = object({
    dns_zone_ids             = list(string)
    default_nginx_controller = optional(bool)
  })
  default     = null
  description = "Web App Routing configuration (DNS Zone IDs)."
}

variable "network_mode" {
  type        = string
  default     = null
  description = "Network mode to be used with Azure CNI. Possible values are bridge and transparent"
}

variable "pod_cidrs" {
  type        = list(string)
  default     = null
  description = "List of CIDR ranges for pods when using multiple pod CIDRs with network plugin"
}

variable "service_cidrs" {
  type        = list(string)
  default     = null
  description = "List of CIDR ranges for services when using multiple service CIDRs"
}

variable "ip_versions" {
  type        = list(string)
  default     = null
  description = "IP versions to use for the cluster network. Possible values are IPv4 and IPv6"
}

variable "nat_gateway_profile" {
  type = object({
    idle_timeout_in_minutes   = number
    managed_outbound_ip_count = number
  })
  default     = null
  description = "NAT Gateway profile configuration for managing outbound connectivity with idle timeout and IP count"
}

variable "advanced_networking" {
  type = object({
    observability_enabled = bool
    security_enabled      = bool
  })
  default     = null
  description = "Advanced networking configuration to enable observability and security features for the cluster"
}

variable "gateway_id" {
  description = "ID of an existing Application Gateway to integrate with AKS (BYO App Gateway)."
  type        = string
  default     = null
}

variable "upgrade_override" {
  type = object({
    force_upgrade_enabled = bool
    effective_until       = string
  })
  default     = null
  description = "Upgrade override configuration to force cluster upgrades until a specified date/time"
}

variable "enable_ingress_application_gateway" {
  type        = bool
  default     = false
  description = "Enable Application Gateway Ingress Controller (AGIC) for AKS"
}

variable "ingress_application_gateway" {
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_id    = optional(string)
    subnet_cidr  = optional(string)
  })
  default     = null
  description = "AGIC configuration for AKS. Use gateway_id for existing App Gateway, or gateway_name with subnet_id/subnet_cidr for AKS-managed gateway."
  validation {
    condition = (
      var.ingress_application_gateway == null ||

      (
        var.ingress_application_gateway.gateway_id != null &&
        var.ingress_application_gateway.gateway_name == null &&
        var.ingress_application_gateway.subnet_id == null &&
        var.ingress_application_gateway.subnet_cidr == null
      ) ||

      (
        var.ingress_application_gateway.gateway_id == null &&
        var.ingress_application_gateway.gateway_name != null &&
        (
          var.ingress_application_gateway.subnet_id != null ||
          var.ingress_application_gateway.subnet_cidr != null
        )
      )
    )

    error_message = "Invalid ingress_application_gateway config. Use only gateway_id OR gateway_name with subnet_id/subnet_cidr."
  }

}

##-----------------------------------------------------------------------------
## Storage Configuration
##-----------------------------------------------------------------------------
variable "storage_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable storage profile"
  nullable    = false
}

variable "storage_profile" {
  type = object({
    enabled                     = bool
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    disk_driver_version         = string
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })
  default = {
    enabled                     = false
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    disk_driver_version         = "v1"
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
  description = "Storage profile configuration"
}

##-----------------------------------------------------------------------------
## Monitoring and Logging
##-----------------------------------------------------------------------------
variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of Log Analytics workspace"
}

variable "msi_auth_for_monitoring_enabled" {
  type        = bool
  default     = false
  description = "Enable managed identity auth for monitoring?"
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "AzureDiagnostics or Dedicated (LA tables)."
}

variable "diagnostic_setting_enable" {
  type        = bool
  description = "Enable or disable diagnostic settings for this resource"
  default     = false
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Destination Storage Account ID for Diagnostic Settings."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Destination Event Hub name for Diagnostic Settings."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Event Hub auth rule ID for Diagnostic Settings."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Diagnostic Metric enabled?"
}

variable "pip_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })
  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
  description = "Configuration for Public IP diagnostic log settings. Specify log categories or category groups to collect"
}

variable "aks_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })
  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
  description = "Configuration for AKS diagnostic log settings. Specify log categories or category groups to collect"
}

##-----------------------------------------------------------------------------
## Image Cleaner Configuration
##-----------------------------------------------------------------------------
variable "image_cleaner_enabled" {
  type        = bool
  default     = false
  description = "Enable Image Cleaner."
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "Interval (hours) for image cleanup."
}

##-----------------------------------------------------------------------------
## HTTP Proxy Configuration
##-----------------------------------------------------------------------------
variable "enable_http_proxy" {
  type        = bool
  default     = false
  description = "Enable HTTP proxy configuration."
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })
  default     = null
  description = "HTTP Proxy configuration"
}

##-----------------------------------------------------------------------------
## Maintenance Windows
##-----------------------------------------------------------------------------
variable "maintenance_window_node_os" {
  type = object({
    day_of_month = optional(number)
    day_of_week  = optional(string)
    duration     = number
    frequency    = string
    interval     = number
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(set(object({
      end   = string
      start = string
    })))
  })
  default     = null
  description = "Maintenance window for node OS."
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    start_date   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default     = null
  description = "Maintenance window for auto-upgrades."
}

##-----------------------------------------------------------------------------
## Confidential Computing
##-----------------------------------------------------------------------------
variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })
  default     = null
  description = "Enable Confidential Computing (SGX)."
}

##-----------------------------------------------------------------------------
## Key Vault Integration
##-----------------------------------------------------------------------------
variable "key_vault_id" {
  type        = string
  default     = null
  description = "Key Vault (or Key URL) used for Disk Encryption Set, etc."
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  default     = false
  description = "Enable Secrets Store CSI Driver (AKV provider)."
  nullable    = false
}

variable "secret_rotation_enabled" {
  type        = bool
  default     = false
  description = "Enable secret rotation (requires AKV CSI)."
  nullable    = false
}

variable "secret_rotation_interval" {
  type        = string
  default     = "2m"
  description = "Secret rotation poll interval (used when rotation enabled)."
  nullable    = false
}

variable "rotation_policy_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable rotation policy"
}

variable "rotation_policy" {
  type = map(object({
    time_before_expiry   = string
    expire_after         = string
    notify_before_expiry = string
  }))
  default = {
    example_rotation_policy = {
      time_before_expiry   = "P30D"
      expire_after         = "P90D"
      notify_before_expiry = "P29D"
    }
  }
  description = "Key Vault certificate rotation policy configuration with ISO 8601 duration format (e.g., P30D for 30 days)"
}

variable "expiration_date" {
  type        = string
  default     = "2026-09-17T23:59:59Z"
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
}

##-----------------------------------------------------------------------------
## Customer-Managed Keys (CMK) Configuration
##-----------------------------------------------------------------------------
variable "cmk_enabled" {
  type        = bool
  default     = true
  description = "Flag to control resource creation related to CMK encryption."
}

variable "cmk_key_type" {
  type        = string
  default     = "RSA"
  description = "Key type (e.g., RSA, EC)."
}

variable "cmk_key_size" {
  type        = number
  default     = 2048
  description = "Key size for RSA (2048/3072/4096)."
}

variable "cmk_key_ops" {
  type        = set(string)
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  description = "Allowed key operations."
}

variable "cmk_des_key_permissions" {
  type        = list(string)
  default     = ["Get", "WrapKey", "UnwrapKey"]
  description = "Key permissions for the Disk Encryption Set identity."
}

variable "cmk_des_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the Disk Encryption Set identity."
}

variable "cmk_aks_key_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Key permissions for the AKS managed identity."
}

variable "cmk_aks_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the AKS managed identity."
}

variable "cmk_aks_secret_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Secret permissions for the AKS managed identity."
}

variable "cmk_kubelet_key_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Key permissions for the kubelet identity."
}

variable "cmk_kubelet_certificate_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Certificate permissions for the kubelet identity."
}

variable "cmk_kubelet_secret_permissions" {
  type        = list(string)
  default     = ["Get"]
  description = "Secret permissions for the kubelet identity."
}

##-----------------------------------------------------------------------------
## KMS Configuration
##-----------------------------------------------------------------------------
variable "kms_enabled" {
  type        = bool
  default     = false
  description = "Enable Azure KeyVault Key Management Service."
}

variable "kms_key_vault_key_id" {
  type        = string
  default     = null
  description = "Identifier of Azure Key Vault key (required if KMS enabled)."
}

variable "kms_key_vault_network_access" {
  type        = string
  default     = "Public"
  description = "Key Vault network access: `Private` or `Public`."
  validation {
    condition     = contains(["Private", "Public"], var.kms_key_vault_network_access)
    error_message = "Possible values are `Private` and `Public`"
  }
}

##-----------------------------------------------------------------------------
## AKS Backup Configuration
##-----------------------------------------------------------------------------
variable "enable_backup" {
  type        = bool
  default     = false
  description = "This enables the aks backup Vault"
}

variable "vault_datastore_type" {
  type        = string
  default     = "VaultStore"
  description = "(Required) Specifies the type of the data store. Possible values are ArchiveStore, OperationalStore, SnapshotStore and VaultStore. Changing this forces a new resource to be created."
}

variable "aks_backup_redundancy" {
  type        = string
  default     = "LocallyRedundant"
  description = "(Required) Specifies the backup storage redundancy. Possible values are GeoRedundant, LocallyRedundant and ZoneRedundant. Changing this forces a new Backup Vault to be created."
}

variable "retention_rules" {
  type = list(object({
    name     = string
    priority = number
    life_cycle = object({
      duration        = string
      data_store_type = string
    })
    criteria = object({
      absolute_criteria      = optional(string)
      days_of_week           = optional(list(string))
      months_of_year         = optional(list(string))
      weeks_of_month         = optional(list(string))
      scheduled_backup_times = optional(list(string))
    })
  }))
  default     = []
  description = "List of retention rules with lifecycle and criteria details."
}

variable "default_retention_rules" {
  type = map(object({
    duration        = string
    data_store_type = string
  }))
  default = {
    default = {
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }
  }
  description = "Map of retention rules with their lifecycle configurations"
}

variable "backup_datasource_parameters" {
  type = object({
    excluded_namespaces              = optional(list(string))
    excluded_resource_types          = optional(list(string))
    cluster_scoped_resources_enabled = bool
    included_namespaces              = list(string)
    included_resource_types          = optional(list(string))
    label_selectors                  = optional(list(string))
    volume_snapshot_enabled          = bool
  })
  default = {
    excluded_namespaces              = null
    included_namespaces              = null
    included_resource_types          = null
    excluded_resource_types          = null
    label_selectors                  = null
    cluster_scoped_resources_enabled = false
    volume_snapshot_enabled          = false
  }
  description = "Configuration parameters for backup datasource"
}

variable "backup_release_train" {
  type        = string
  default     = "Stable"
  description = "(Optional) The release train used by this extension. Possible values include but are not limited to Stable, Preview. Changing this forces a new Kubernetes Cluster Extension to be created."
}

variable "backup_release_namespace" {
  type        = string
  default     = "dataprotection-microsoft"
  description = "(Optional) Namespace where the extension release must be placed for a cluster scoped extension. If this namespace does not exist, it will be created."
}

variable "snapshot_resource_group_id" {
  type        = string
  default     = null
  description = "(Required) The Id of the Resource Group where snapshots are stored."
}

variable "snapshot_resource_group_name" {
  type        = string
  default     = null
  description = "(Required) The name of the Resource Group where snapshots are stored."
}

variable "backup_storage_account_id" {
  type        = string
  default     = null
  description = "ID of the existing storage account for backup data. If null, a new storage account will be created."
}

variable "backup_storage_account_name" {
  type        = string
  default     = null
  description = "Name of the storage account where backup data will be stored"
}

variable "backup_container_name" {
  type        = string
  default     = "backup"
  description = "Name of the container within the storage account where backup data will be stored"
}

variable "backup_repeating_time_intervals" {
  type        = list(string)
  description = "List of repeating time intervals for AKS backup in ISO 8601 format."
  default     = ["R/2026-01-26T00:00:00Z/P1D"]
}


##-----------------------------------------------------------------------------
## Extensions
##-----------------------------------------------------------------------------
variable "enable_extensions" {
  type        = bool
  description = "Enable Kubernetes cluster extensions"
  default     = false
}

variable "extension_type" {
  type        = string
  description = "Type of the Kubernetes cluster extension (e.g., microsoft.flux, microsoft.dapr, microsoft.azuremonitor.containers)"
  default     = "microsoft.flux"
}

variable "configuration_settings" {
  type        = map(string)
  description = "Configuration settings for the extension as key-value pairs"
  default     = {}
}

variable "configuration_protected_settings" {
  type        = map(string)
  description = "Protected/sensitive configuration settings for the extension"
  sensitive   = true
  default     = {}
}

variable "enable_plan" {
  type        = bool
  description = "Enable marketplace plan configuration for the extension"
  default     = false
}

variable "plan_config" {
  type = object({
    name           = string
    product        = string
    publisher      = string
    promotion_code = optional(string)
    version        = optional(string)
  })
  description = "Marketplace plan configuration object containing name, product, publisher and optional promotion_code and version"
  default     = null
}

variable "release_train" {
  type        = string
  description = "Release train for the extension (Stable or Preview)"
  default     = "Stable"
  validation {
    condition     = var.release_train == null || contains(["Stable", "Preview"], var.release_train)
    error_message = "release_train must be either 'Stable' or 'Preview' or null"
  }
}

variable "release_namespace" {
  type        = string
  description = "Namespace where the extension release resources will be created"
  default     = null
}

variable "target_namespace" {
  type        = string
  description = "Target namespace where the extension will be deployed"
  default     = null
}

variable "extension_version" {
  type        = string
  description = "Version of the extension to install. If not specified, latest version will be used"
  default     = null
}

##-----------------------------------------------------------------------------
## Kubernetes Fleet Manager
##-----------------------------------------------------------------------------
variable "enable_fleet_manager" {
  type        = bool
  description = "Enable Kubernetes Fleet Manager for multi-cluster management"
  default     = false
}

variable "fleet_member_group" {
  type        = string
  description = "The group this member belongs to for orchestration. Used for update runs and other operations"
  default     = null
}

variable "enable_fleet_update_strategy" {
  type        = bool
  description = "Enable Fleet Update Strategy for reusable update orchestration patterns"
  default     = false
}

variable "fleet_update_strategy_stages" {
  type = list(object({
    name                        = string
    groups                      = list(string)
    after_stage_wait_in_seconds = optional(number)
  }))
  description = "List of update strategy stages with groups and wait times"
  default     = []
}

variable "enable_fleet_update_run" {
  type        = bool
  description = "Enable Fleet Update Run for orchestrated cluster updates"
  default     = false
}

variable "fleet_upgrade_type" {
  type        = string
  description = "Type of upgrade: 'Full' or 'NodeImageOnly'"
  default     = "Full"
  validation {
    condition     = contains(["Full", "NodeImageOnly"], var.fleet_upgrade_type)
    error_message = "fleet_upgrade_type must be either 'Full' or 'NodeImageOnly'"
  }
}

variable "fleet_upgrade_kubernetes_version" {
  type        = string
  description = "Kubernetes version to upgrade to (required when type is 'Full')"
  default     = null
}

variable "fleet_node_image_selection_type" {
  type        = string
  description = "Node image selection type: 'Latest' or 'Consistent'"
  default     = null
}

variable "fleet_update_stages" {
  type = list(object({
    name                        = string
    groups                      = list(string)
    after_stage_wait_in_seconds = optional(number)
  }))
  description = "Inline update stages (used only when fleet_update_strategy is disabled)"
  default     = []
}

##-----------------------------------------------------------------------------
## Kubernetes Flux Configuration
##-----------------------------------------------------------------------------
variable "enable_flux_configuration" {
  type        = bool
  description = "Enable Flux GitOps configuration for the AKS cluster"
  default     = false
}

variable "flux_namespace" {
  type        = string
  description = "Namespace where Flux configuration will be installed"
  default     = "flux-system"
}

variable "flux_scope" {
  type        = string
  description = "Scope of the Flux configuration: 'cluster' or 'namespace'"
  default     = "cluster"
  validation {
    condition     = contains(["cluster", "namespace"], var.flux_scope)
    error_message = "flux_scope must be either 'cluster' or 'namespace'"
  }
}

variable "flux_continuous_reconciliation_enabled" {
  type        = bool
  description = "Enable continuous reconciliation for Flux configuration"
  default     = true
}

variable "flux_kustomizations" {
  type = list(object({
    name                       = string
    path                       = optional(string, "./")
    timeout_in_seconds         = optional(number, 600)
    sync_interval_in_seconds   = optional(number, 600)
    retry_interval_in_seconds  = optional(number, 300)
    recreating_enabled         = optional(bool, false)
    garbage_collection_enabled = optional(bool, true)
    depends_on                 = optional(list(string), [])
    wait                       = optional(bool, true)
    post_build = optional(object({
      substitute = optional(map(string))
      substitute_from = optional(list(object({
        kind     = string
        name     = string
        optional = optional(bool)
      })))
    }))
  }))
  description = "List of Flux Kustomizations (required when enable_flux_configuration is true)"
  default = [
    {
      name = "default"
      path = "./"
    }
  ]
}

##-----------------------------------------------------------------------------
## Flux Source Configuration (Choose one: git_repository, bucket, or blob_storage)
##-----------------------------------------------------------------------------
variable "flux_git_repository" {
  type = object({
    url                      = string
    reference_type           = string
    reference_value          = string
    https_ca_cert_base64     = optional(string)
    https_user               = optional(string)
    https_key_base64         = optional(string)
    provider                 = optional(string)
    local_auth_reference     = optional(string)
    ssh_private_key_base64   = optional(string)
    ssh_known_hosts_base64   = optional(string)
    sync_interval_in_seconds = optional(number)
    timeout_in_seconds       = optional(number)
  })
  description = "Git repository configuration for Flux source"
  sensitive   = true
  default     = null
}

variable "flux_bucket" {
  type = object({
    bucket_name              = string
    url                      = string
    access_key               = optional(string)
    secret_key_base64        = optional(string)
    tls_enabled              = optional(bool, true)
    local_auth_reference     = optional(string)
    sync_interval_in_seconds = optional(number)
    timeout_in_seconds       = optional(number)
  })
  description = "S3-compatible bucket configuration for Flux source"
  sensitive   = true
  default     = null
}

variable "flux_blob_storage" {
  type = object({
    container_id             = string
    account_key              = optional(string)
    local_auth_reference     = optional(string)
    sas_token                = optional(string)
    sync_interval_in_seconds = optional(number)
    timeout_in_seconds       = optional(number)
    managed_identity = optional(object({
      client_id = string
    }))
    service_principal = optional(object({
      client_id                     = string
      tenant_id                     = string
      client_certificate_base64     = optional(string)
      client_certificate_password   = optional(string)
      client_certificate_send_chain = optional(bool)
      client_secret                 = optional(string)
    }))
  })
  description = "Azure Blob Storage configuration for Flux source"
  sensitive   = true
  default     = null
}
