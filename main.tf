##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
provider "azurerm" {
  features {}

  use_msi         = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
