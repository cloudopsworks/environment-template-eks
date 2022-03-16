##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
variable "default_helm_repo" {
  type    = string
  default = "finconectaopsclusterprod.azurecr.io"
}

variable "default_namespace" {
  type    = string
  default = "default"
}