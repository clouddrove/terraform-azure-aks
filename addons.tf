data "azurerm_kubernetes_cluster" "credentials" {
  depends_on          = [azurerm_kubernetes_cluster.aks]
  name                = azurerm_kubernetes_cluster.aks[0].name
  resource_group_name = local.resource_group_name
}

resource "null_resource" "get_kubeconfig" {
  count = var.enable_adddons ? 1 : 0
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${azurerm_kubernetes_cluster.aks[0].name}  --overwrite-existing && kubelogin convert-kubeconfig -l azurecli"
  }
  # The triggers argument ensures that the null_resource is recreated on each apply
  triggers = {
    always_run = "${timestamp()}"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

module "istio_ingress" {
  count                       = var.istio_ingress && var.enable_adddons ? 1 : 0
  depends_on                  = [azurerm_kubernetes_cluster.aks]
  source                      = "./addons/istio/"
  helm_config                 = var.istio_ingress_helm_config != null ? var.istio_ingress_helm_config : { values = [local_file.istio_ingress_helm_config[count.index].content] }
  manage_via_gitops           = var.manage_via_gitops
  istio_manifests             = var.istio_manifests
  istio_ingress_extra_configs = var.istio_ingress_extra_configs
}

#--------------------------- ISTIO INGRESS ----------------------------------
resource "local_file" "istio_ingress_helm_config" {
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.node_pools]
  count      = var.istio_ingress && (var.istio_ingress_helm_config == null) && var.enable_adddons ? 1 : 0
  content    = <<EOT

  EOT
  filename   = "${path.module}/override_values/istio_ingress.yaml"
}

module "kubecost" {
  count                  = var.kubecost && var.enable_adddons ? 1 : 0
  depends_on             = [azurerm_kubernetes_cluster.aks]
  source                 = "./addons/kubecost/"
  helm_config            = var.kubecost_helm_config != null ? var.kubecost_helm_config : { values = [local_file.kubecost_helm_config[count.index].content] }
  manage_via_gitops      = var.manage_via_gitops
  kubecost_manifests     = var.kubecost_manifests
  kubecost_extra_configs = var.kubecost_extra_configs
}

#--------------------------- ISTIO INGRESS ----------------------------------
resource "local_file" "kubecost_helm_config" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  count      = var.kubecost && (var.kubecost_helm_config == null) && var.enable_adddons ? 1 : 0
  content    = <<EOT
   kubecostToken: "aGVsbUBrdWJlY29zdC5jb20=xm343yadf98"
  EOT
  filename   = "${path.module}/override_values/kubecost.yaml"
}