resource "azurerm_kubernetes_cluster_extension" "flux" {
  depends_on     = [azurerm_kubernetes_cluster.aks]
  count          = var.flux_enable ? 1 : 0
  name           = "flux-extension"
  cluster_id     = join("", azurerm_kubernetes_cluster.aks[0].id)
  extension_type = "microsoft.flux"
  configuration_settings = {
    "image-automation-controller.ssh-host-key-args" = "--ssh-hostkey-algos=rsa-sha2-512,rsa-sha2-256"
    "multiTenancy.enforce"                          = "false"
    "source-controller.ssh-host-key-args"           = "--ssh-hostkey-algos=rsa-sha2-512,rsa-sha2-256"
  }
}

resource "azurerm_kubernetes_flux_configuration" "flux" {
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_extension.flux]
  count      = var.flux_enable ? 1 : 0
  name       = "flux-conf"
  cluster_id = join("", azurerm_kubernetes_cluster.aks[0].id)
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                    = var.flux_git_repo_url != "" ? var.flux_git_repo_url : ""
    reference_type         = "branch"
    reference_value        = var.flux_git_repo_branch
    ssh_private_key_base64 = var.ssh_private_key_base64 != "" ? var.ssh_private_key_base64 : ""
  }

  kustomizations {
    name                      = "flux-system-kustomization"
    timeout_in_seconds        = var.flux_timeout_in_seconds
    sync_interval_in_seconds  = var.flux_sync_interval_in_seconds
    retry_interval_in_seconds = var.flux_retry_interval_in_seconds
  }
}