#Module      : LABEL
#Description : Terraform label module variables.

variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-azure-aks.git"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  default     = null
  description = "Location where resource should be created."
}

variable "kubernetes_version" {
  type        = string
  default     = "1..27.7"
  description = "Version of Kubernetes to deploy"
}

variable "workload_runtime" {
  type        = string
  default     = null
  description = "Used to specify the workload runtime. Allowed values are OCIContainer, WasmWasi and KataMshvVmIsolation."
}

variable "agents_pool_name" {
  type        = string
  default     = "nodepool"
  description = "The default Azure AKS agentpool (nodepool) name."
  nullable    = false
}

variable "agents_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created."
}

variable "enable_auto_scaling" {
  type        = bool
  default     = false
  description = "Enable node pool autoscaling"
}

variable "enable_host_encryption" {
  type        = bool
  default     = false
  description = "Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli"
}

variable "enable_node_public_ip" {
  type        = bool
  default     = false
  description = "(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false."
}

variable "default_node_pool_fips_enabled" {
  type        = bool
  default     = null
  description = " (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created."
}

variable "agents_max_count" {
  type        = number
  default     = null
  description = "Maximum number of nodes in a pool"
}

variable "agents_max_pods" {
  type        = number
  default     = null
  description = "The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
}

variable "agents_min_count" {
  type        = number
  default     = null
  description = "Minimum number of nodes in a pool"
}

variable "agents_labels" {
  type        = map(string)
  default     = {}
  description = "A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
}

variable "only_critical_addons_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint. Changing this forces a new resource to be created."
}

variable "orchestrator_version" {
  type        = string
  default     = null
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
}

variable "os_disk_size_gb" {
  type        = number
  default     = 50
  description = "Disk size of nodes in GBs."
}

variable "os_disk_type" {
  type        = string
  default     = "Managed"
  description = "The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created."
  nullable    = false
}

variable "os_sku" {
  type        = string
  default     = null
  description = "(Optional) Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if OSType=Linux or `Windows2019` if OSType=Windows. And the default Windows OSSKU will be changed to `Windows2022` after Windows2019 is deprecated. Changing this forces a new resource to be created."
}

variable "pod_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created."
}

variable "agents_proximity_placement_group_id" {
  type        = string
  default     = null
  description = "The ID of the Proximity Placement Group of the default Azure AKS agentpool (nodepool). Changing this forces a new resource to be created."
}

variable "scale_down_mode" {
  type        = string
  default     = "Delete"
  description = "Specifies the autoscaling behaviour of the Kubernetes Cluster. If not specified, it defaults to `Delete`. Possible values include `Delete` and `Deallocate`. Changing this forces a new resource to be created."
}

variable "snapshot_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Snapshot which should be used to create this default Node Pool. `temporary_name_for_rotation` must be specified when changing this property."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Any tags that should be present on the AKS cluster resources"
}

variable "agents_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the Node Pool."
}

variable "temporary_name_for_rotation" {
  type        = string
  default     = null
  description = "Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing. the `var.agents_size` is no longer ForceNew and can be resized by specifying `temporary_name_for_rotation`"
}

variable "agents_type" {
  type        = string
  default     = "VirtualMachineScaleSets"
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets."
}

variable "ultra_ssd_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false."
}

variable "vnet_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
}

variable "agents_availability_zones" {
  type        = list(string)
  default     = null
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
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

variable "agents_pool_max_surge" {
  type        = string
  default     = null
  description = "The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade."
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



variable "aks_sku_tier" {
  type        = string
  default     = "Free"
  description = "aks sku tier. Possible values are Free ou Paid"
}

variable "private_cluster_enabled" {
  type        = bool
  default     = true
  description = "Configure AKS as a Private Cluster : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_cluster_enabled"
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Ip ranges allowed to interract with Kubernetes API. Default no restrictions"
}

variable "node_resource_group" {
  type        = string
  default     = null
  description = "Name of the resource group in which to put AKS nodes. If null default to MC_<AKS RG Name>"
}

variable "private_dns_zone_type" {
  type        = string
  default     = "System"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private_dns_zone_id> variable
If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"
and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone
- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#private_dns_zone_id
EOD
}

variable "default_node_pool" {
  description = <<EOD
Default node pool configuration:
```
map(object({
    name                  = string
    count                 = number
    vm_size               = string
    os_type               = string
    availability_zones    = list(number)
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    type                  = string
    vnet_subnet_id        = string
    max_pods              = number
    os_disk_type          = string
    os_disk_size_gb       = number
    enable_node_public_ip = bool
}))
```
EOD

  type    = map(any)
  default = {}
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is custom"
}


variable "linux_profile" {
  description = "Username and ssh key for accessing AKS Linux nodes with ssh."
  type = object({
    username = string,
    ssh_key  = string
  })
  default = null
}

variable "service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR used by kubernetes services (kubectl get svc)."
}

variable "outbound_type" {
  type        = string
  default     = "loadBalancer"
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
}

variable "nodes_subnet_id" {
  type        = string
  default     = null
  description = "Id of the subnet used for nodes"
}

variable "nodes_pools" {
  type        = list(any)
  default     = []
  description = "A list of nodes pools to create, each item supports same properties as `local.default_agent_profile`"

}

variable "vnet_id" {
  type        = string
  default     = null
  description = "Vnet id that Aks MSI should be network contributor in a private cluster"
}

variable "enable_http_application_routing" {
  type        = bool
  default     = false
  description = "Enable HTTP Application Routing Addon (forces recreation)."
}

variable "enable_azure_policy" {
  type        = bool
  default     = true
  description = "Enable Azure Policy Addon."
}

variable "microsoft_defender_enabled" {
  type        = bool
  default     = false
  description = "Enable microsoft_defender_enabled Addon."
}

variable "oms_agent_enabled" {
  type        = bool
  default     = true
  description = "Enable log_analytics_workspace_enabled(oms agent) Addon."
}

variable "service_mesh_profile" {
  type = object({
    mode                             = string
    internal_ingress_gateway_enabled = optional(bool, true)
    external_ingress_gateway_enabled = optional(bool, true)
  })
  default     = null
  description = <<-EOT
    `mode` - (Required) The mode of the service mesh. Possible value is `Istio`.
    `internal_ingress_gateway_enabled` - (Optional) Is Istio Internal Ingress Gateway enabled? Defaults to `true`.
    `external_ingress_gateway_enabled` - (Optional) Is Istio External Ingress Gateway enabled? Defaults to `true`.
  EOT
}

variable "client_id" {
  type        = string
  default     = ""
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  nullable    = false
}

variable "client_secret" {
  type        = string
  default     = ""
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  nullable    = false
}

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

variable "web_app_routing" {
  type = object({
    dns_zone_id = string
  })
  default     = null
  description = <<-EOT
  object({
    dns_zone_id = "(Required) Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when Web App Routing is enabled."
  })
EOT
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
  description = "The ID of log analytics"
}
variable "msi_auth_for_monitoring_enabled" {
  type        = bool
  default     = false
  description = " Is managed identity authentication for monitoring enabled?"
}

variable "network_plugin" {
  type        = string
  default     = "azure"
  description = "Network plugin to use for networking."
}

variable "network_policy" {
  type        = string
  default     = null
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
}

variable "acr_enabled" {
  type        = bool
  default     = false
  description = "The enable and disable the acr access for aks"
}

variable "acr_id" {
  type        = string
  default     = null
  description = "azure container resource id to provide access for aks"
}

variable "auto_scaler_profile_enabled" {
  type        = bool
  default     = false
  description = "Enable configuring the auto scaler profile"
  nullable    = false
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret"
}

variable "role_based_access_control" {
  type = list(object({
    managed                = bool
    tenant_id              = string
    admin_group_object_ids = list(string)
    azure_rbac_enabled     = bool
  }))
  default = null
  # default = {
  #  managed  = true
  #  tenant_id  = null
  #  admin_group_object_ids  = null
  #  azure_rbac_enabled = false
  # }
}

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

variable "load_balancer_profile_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable a load_balancer_profile block. This can only be used when load_balancer_sku is set to `standard`."
  nullable    = false
}

variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created."

  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}

variable "network_plugin_mode" {
  type        = string
  default     = null
  description = "(Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is `Overlay`. Changing this forces a new resource to be created."
}

variable "net_profile_pod_cidr" {
  type        = string
  default     = null # "10.244.0.0/16"
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
}

variable "ebpf_data_plane" {
  type        = string
  default     = null
  description = "(Optional) Specifies the eBPF data plane used for building the Kubernetes network. Possible value is `cilium`. Changing this forces a new resource to be created."
}

variable "capacity_reservation_group_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the eBPF data plane used for building the Kubernetes network. Possible value is `cilium`. Changing this forces a new resource to be created."
}

# Diagnosis Settings Enable
variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account id to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
}

variable "diagnostic_setting_enable" {
  type    = bool
  default = false
}

variable "cmk_enabled" {
  type        = bool
  default     = true
  description = "Flag to control resource creation related to cmk encryption."
}

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

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool, false)
    vertical_pod_autoscaler_enabled = optional(bool, false)
  })
  default     = null
  description = <<-EOT
    `keda_enabled` - (Optional) Specifies whether KEDA Autoscaler can be used for workloads.
    `vertical_pod_autoscaler_enabled` - (Optional) Specifies whether Vertical Pod Autoscaler should be enabled.
EOT
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
  description = <<-EOT
 - `day_of_month` -
 - `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.
 - `duration` - (Required) The duration of the window for maintenance to run in hours.
 - `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.
 - `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.
 - `start_date` - (Optional) The date on which the maintenance window begins to take effect.
 - `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.
 - `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.
 - `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.

 ---
 `not_allowed` block supports the following:
 - `end` - (Required) The end of a time span, formatted as an RFC3339 string.
 - `start` - (Required) The start of a time span, formatted as an RFC3339 string.
EOT
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
  description = "(Optional) Maintenance window configuration for auto-upgrades."
}

variable "node_public_ip_tags" {
  type        = map(string)
  default     = {}
  description = "Node network profile configuration"
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
  description = <<-EOT
    list(object({
      cpu_manager_policy        = (Optional) Specifies the CPU Manager policy to use. Possible values are `none` and `static`, Changing this forces a new resource to be created.
      cpu_cfs_quota_enabled     = (Optional) Is CPU CFS quota enforcement for containers enabled? Changing this forces a new resource to be created.
      cpu_cfs_quota_period      = (Optional) Specifies the CPU CFS quota period value. Changing this forces a new resource to be created.
      image_gc_high_threshold   = (Optional) Specifies the percent of disk usage above which image garbage collection is always run. Must be between `0` and `100`. Changing this forces a new resource to be created.
      image_gc_low_threshold    = (Optional) Specifies the percent of disk usage lower than which image garbage collection is never run. Must be between `0` and `100`. Changing this forces a new resource to be created.
      topology_manager_policy   = (Optional) Specifies the Topology Manager policy to use. Possible values are `none`, `best-effort`, `restricted` or `single-numa-node`. Changing this forces a new resource to be created.
      allowed_unsafe_sysctls    = (Optional) Specifies the allow list of unsafe sysctls command or patterns (ending in `*`). Changing this forces a new resource to be created.
      container_log_max_size_mb = (Optional) Specifies the maximum size (e.g. 10MB) of container log file before it is rotated. Changing this forces a new resource to be created.
      container_log_max_line    = (Optional) Specifies the maximum number of container log files that can be present for a container. must be at least 2. Changing this forces a new resource to be created.
      pod_max_pid               = (Optional) Specifies the maximum number of processes per pod. Changing this forces a new resource to be created.
  }))
EOT
}

variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = <<-EOT
 - `client_id` - (Optional) The Client ID of the user-defined Managed Identity to be assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.
 - `object_id` - (Optional) The Object ID of the user-defined Managed Identity assigned to the Kubelets.If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.
 - `user_assigned_identity_id` - (Optional) The ID of the User Assigned Identity assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.
EOT
}

variable "outbound_nat_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether Windows nodes in this Node Pool have outbound NAT enabled. Defaults to true. Changing this forces a new resource to be created."
}

variable "kms_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable Azure KeyVault Key Management Service."
}

variable "kms_key_vault_key_id" {
  type        = string
  default     = null
  description = "(Optional) Identifier of Azure Key Vault key. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier."
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether to use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster. For more details: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver"
  nullable    = false
}

variable "secret_rotation_interval" {
  type        = string
  default     = "2m"
  description = "The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true` and defaults to `2m`"
  nullable    = false
}

variable "secret_rotation_enabled" {
  type        = bool
  default     = false
  description = "Is secret rotation enabled? This variable is only used when `key_vault_secrets_provider_enabled` is `true` and defaults to `false`"
  nullable    = false
}


variable "kms_key_vault_network_access" {
  type        = string
  default     = "Public"
  description = "(Optional) Network Access of Azure Key Vault. Possible values are: `Private` and `Public`."

  validation {
    condition     = contains(["Private", "Public"], var.kms_key_vault_network_access)
    error_message = "Possible values are `Private` and `Public`"
  }
}

variable "ingress_application_gateway" {
  type = list(object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(list(string))
  }))
  default     = null
  description = "The instruction detection block"
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "(Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`."
}

variable "image_cleaner_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether Image Cleaner is enabled."
}

variable "enable_http_proxy" {
  type        = bool
  default     = false
  description = "Enable HTTP proxy configuration."
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "Specifies the Edge Zone within the Azure Region where this Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
}

variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })
  default     = null
  description = "(Optional) Enable Confidential Computing."
}

variable "load_balancer_profile_idle_timeout_in_minutes" {
  type        = number
  default     = 30
  description = "(Optional) Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive."
}

variable "load_balancer_profile_managed_outbound_ip_count" {
  type        = number
  default     = null
  description = "(Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive"
}

variable "load_balancer_profile_managed_outbound_ipv6_count" {
  type        = number
  default     = null
  description = "(Optional) The desired number of IPv6 outbound IPs created and managed by Azure for the cluster load balancer. Must be in the range of `1` to `100` (inclusive). The default value is `0` for single-stack and `1` for dual-stack. Note: managed_outbound_ipv6_count requires dual-stack networking. To enable dual-stack networking the Preview Feature Microsoft.ContainerService/AKS-EnableDualStack needs to be enabled and the Resource Provider re-registered, see the documentation for more information. https://learn.microsoft.com/en-us/azure/aks/configure-kubenet-dual-stack?tabs=azure-cli%2Ckubectl#register-the-aks-enabledualstack-preview-feature"
}

variable "load_balancer_profile_outbound_ip_address_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer."
}

variable "load_balancer_profile_outbound_ip_prefix_ids" {
  type        = set(string)
  default     = null
  description = "(Optional) The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer."
}

variable "load_balancer_profile_outbound_ports_allocated" {
  type        = number
  default     = 0
  description = "(Optional) Number of desired SNAT port for each VM in the clusters load balancer. Must be between `0` and `64000` inclusive. Defaults to `0`"
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = bool
    empty_bulk_delete_max            = number
    expander                         = string
    max_graceful_termination_sec     = string
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
    scan_interval                    = string
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
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
  description = "Auto scaler profile configuration"
}

variable "api_server_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Subnet where the API server endpoint is delegated to."
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = null
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information"
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Is this Diagnostic Metric enabled? Defaults to true."
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
}

variable "kv_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })

  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
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
}

variable "rotation_policy_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable rotation policy"
}
