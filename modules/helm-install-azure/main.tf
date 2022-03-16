##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  values_file      = "values/${var.release_name}-values.yaml"
  values_file_sha1 = filesha1(local.values_file)
  vars_values_sha1_list = [for item_key, item_value in var.vars :
    format("%s-%s", sha1(item_key), sha1(item_value))
  ]
  vars_values_sha1 = join("|", local.vars_values_sha1_list)
}
data "kubernetes_namespace" "release_ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "app_release" {
  count      = var.oci_repo ? 0 : 1
  name       = var.release_name
  chart      = var.chart_name
  namespace  = data.kubernetes_namespace.release_ns.metadata.0.name
  repository = "https://${var.helm_repo}/"
  version    = var.chart_version
  wait       = false

  values = [
    file(local.values_file)
  ]

  dynamic "set_sensitive" {
    for_each = var.vars

    content {
      name  = set_sensitive.key
      value = replace(set_sensitive.value, ",", "\\,")
      type  = "string"
    }
  }
}

resource "null_resource" "helm_init_oci" {
  count = var.oci_repo ? 1 : 0

  triggers = {
    always_run = local.values_file_sha1
    on_version = var.chart_version
    on_vars    = local.vars_values_sha1
  }


  provisioner "local-exec" {
    command = "echo \"$HELM_CREDS_PASSWORD\" | helm registry login ${var.helm_repo} --username $HELM_CREDS_USER --password-stdin"
  }

  provisioner "local-exec" {
    command = "helm chart pull ${var.helm_repo}/${var.chart_name}:${var.chart_version}"
  }

  provisioner "local-exec" {
    command = "helm chart export ${var.helm_repo}/${var.chart_name}:${var.chart_version} --destination ./.release"
  }
}

resource "helm_release" "app_release_oci" {
  depends_on = [
    null_resource.helm_init_oci
  ]

  count     = var.oci_repo ? 1 : 0
  name      = var.release_name
  chart     = "./.release/${var.chart_name}"
  namespace = data.kubernetes_namespace.release_ns.metadata.0.name
  version   = var.chart_version
  wait      = false

  values = [
    file(local.values_file)
  ]

  dynamic "set_sensitive" {
    for_each = var.vars

    content {
      name  = set_sensitive.key
      value = replace(set_sensitive.value, ",", "\\,")
      type  = "string"
    }
  }
}
