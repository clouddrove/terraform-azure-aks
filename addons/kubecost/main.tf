module "kubecost" {
  source = "../helm"
  count  = try(var.kubecost_extra_configs.install_kubecost, true) ? 1 : 0

  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.kubecost.helm_config
}

resource "kubectl_manifest" "kubecost_vs_manifest" {
  count      = length(var.kubecost_manifests.kubecost_vs_manifest_file_path)
  depends_on = [module.kubecost]
  yaml_body  = file(var.kubecost_manifests.kubecost_vs_manifest_file_path[count.index])
}