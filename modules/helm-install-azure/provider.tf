##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
data "azurerm_resource_group" "azure_rg" {
  name = var.resource_group
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.azure_rg.name
}

locals {
  kube_config = var.ad_rbac ? data.azurerm_kubernetes_cluster.aks_cluster.kube_admin_config.0 : data.azurerm_kubernetes_cluster.aks_cluster.kube_config.0
}

provider "kubernetes" {
  host                   = local.kube_config.host
  username               = local.kube_config.username
  password               = local.kube_config.password
  client_certificate     = base64decode(local.kube_config.client_certificate)
  client_key             = base64decode(local.kube_config.client_key)
  cluster_ca_certificate = base64decode(local.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config.host
    username               = local.kube_config.username
    password               = local.kube_config.password
    client_certificate     = base64decode(local.kube_config.client_certificate)
    client_key             = base64decode(local.kube_config.client_key)
    cluster_ca_certificate = base64decode(local.kube_config.cluster_ca_certificate)
  }
}