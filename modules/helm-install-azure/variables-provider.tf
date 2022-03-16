##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
variable "resource_group" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "ad_rbac" {
  type    = bool
  default = false
}