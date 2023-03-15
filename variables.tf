#Module      : LABEL
#Description : Terraform label module variables.

variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-azure-subnet.git"
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
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "resource_group_name" {
  default     = ""
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  default     = ""
  description = "Location where resource should be created."
}

variable "kubernetes_version" {
  type        = string
  default     = "1..24.3"
  description = "Version of Kubernetes to deploy"
}

variable "aks_sku_tier" {
  type        = string
  default     = "Free"
  description = "aks sku tier. Possible values are Free ou Paid"
}

variable "private_cluster_enabled" {
  type        = bool
  default     = false
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

variable "enable_pod_security_policy" {
  type        = bool
  default     = false
  description = "Enable pod security policy or not. https://docs.microsoft.com/fr-fr/azure/AKS/use-pod-security-policies"
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
    node_taints           = list(string)
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
  description = "CIDR used by kubernetes services (kubectl get svc)."
}

variable "docker_bridge_cidr" {
  type        = string
  default     = "172.16.0.1/16"
  description = "IP address for docker with Network CIDR."
}

variable "outbound_type" {
  type        = string
  default     = "loadBalancer"
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are `loadBalancer` and `userDefinedRouting`."
}

variable "nodes_subnet_id" {
  type        = string
  description = "Id of the subnet used for nodes"
}

variable "nodes_pools" {
  default     = []
  type        = list(any)
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

variable "enable_kube_dashboard" {
  type        = bool
  default     = false
  description = "Enable Kubernetes Dashboard."
}

variable "enable_azure_policy" {
  type        = bool
  default     = false
  description = "Enable Azure Policy Addon."
}

variable "microsoft_defender_enabled" {
  type        = bool
  default     = false
  description = "Enable microsoft_defender_enabled Addon."
}

variable "log_analytics_workspace_enabled" {
  type        = bool
  default     = false
  description = "Enable log_analytics_workspace_enabled(oms agent) Addon."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
  description = "The ID of log analytics"
}

variable "enable_ingress_application_gateway" {
  type        = bool
  default     = null
  description = "Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster?"
}

variable "ingress_application_gateway_id" {
  type        = string
  default     = null
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster."
}

variable "ingress_application_gateway_name" {
  type        = string
  default     = null
  description = "The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
}

variable "ingress_application_gateway_subnet_cidr" {
  type        = string
  default     = null
  description = "The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
}

variable "ingress_application_gateway_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
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

variable "azurerm_disk_encryption_set" {
  type        = bool
  default     = false
  description = "The enable the Disk Encryption Set which should be used for the Nodes and Volumes. M"
}

variable "acr_enabled" {
  type        = bool
  default     = false
  description = "The enable and disable the acr access for aks"
}

variable "acr_id" {
  type        = string
  default     = ""
  description = "azure container resource id to provide access for aks"
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret"
}

variable "microsoft_defender_workspace_id" {
  type        = string
  default     = ""
  description = "The default ID of log analytics"
}

variable "role_based_access_control" {
  type = list(object({
    managed                = bool
    tenant_id              = string
    admin_group_object_ids = list(string)
    azure_rbac_enabled     = bool
  }))
  default = null
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

# variable "log_analytics_workspace_id" {
#   type        = string
#   default     = null
#   description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
# }

variable "retention_policy_enabled" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating retension policy for the diagnosys setting."
}

variable "days" {
  type        = number
  default     = 365
  description = "Number of days to create retension policies for te diagnosys setting."
}

variable "aks_logs_category" {
  type    = list(string)
  default = ["kube-apiserver", "kube-audit", "cluster-autoscaler", "kube-controller-manager", "kube-scheduler", "cloud-controller-manager", "csi-azuredisk-controller", "csi-azurefile-controller", "csi-snapshot-controller", "guard", "kube-audit-admin", ]
}


variable "datastorages" {
  type    = list(string)
  default = null
}

#### enable diagnostic setting
variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
}

variable "diagnostic_log_days" {
  type        = number
  default     = "90"
  description = " The number of days for which this Retention Policy should apply."
}
variable "Metric_enable" {
  type        = bool
  default     = true
  description = "Is this Diagnostic Metric enabled? Defaults to true."
}
variable "diagnostic_setting_enable" {
  type    = bool
  default = false
}

variable "category" {
  type        = string
  default     = null
  description = " The name of a Diagnostic Log Category Group for this Resource."
}
variable "log_enabled" {
  type        = string
  default     = true
  description = " Is this Diagnostic Log enabled? Defaults to true."
}
variable "target_resource_id" {
  type    = string
  default = ""
}
