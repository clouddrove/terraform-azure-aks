variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Set this to `true` if managing addons via GitOps. Seting `true` will not create helm-release for addon."
}

variable "enable_adddons" {
  description = "Enable Istio Ingress add-on"
  type        = bool
  default     = false
}

#-----------ISTIO INGRESS---------------------------
variable "istio_ingress" {
  description = "Enable Istio Ingress add-on"
  type        = bool
  default     = true
}

variable "istio_ingress_helm_config" {
  description = "Path to override-values.yaml for Istio Ingress  Helm Chart"
  type        = any
  default     = null
}

variable "istio_manifests" {
  description = "Path of Ingress and Gateway yaml manifests"
  type = object({

    istio_gateway_manifest_file_path = list(any)
  })
  default = {
    istio_gateway_manifest_file_path = [""]
  }
}

variable "istio_ingress_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default     = {}
}

#-----------KUBECOST ---------------------------
variable "kubecost" {
  description = "Enable Istio Ingress add-on"
  type        = bool
  default     = true
}

variable "kubecost_helm_config" {
  description = "Path to override-values.yaml for Istio Ingress  Helm Chart"
  type        = any
  default     = null
}

variable "kubecost_manifests" {
  description = "Path of Ingress and Gateway yaml manifests"
  type = object({

    kubecost_vs_manifest_file_path = list(any)
  })
  default = {
    kubecost_vs_manifest_file_path = [""]
  }
}

variable "kubecost_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default     = {}
}