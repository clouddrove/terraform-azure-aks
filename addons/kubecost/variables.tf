variable "helm_config" {
  description = "Helm provider config for kubecost"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "kubecost_manifests" {
  type = object({
    kubecost_vs_manifest_file_path = list(any)
  })
}

variable "kubecost_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default     = {}
}