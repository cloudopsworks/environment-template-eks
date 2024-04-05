##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.sts_assume_role
    session_name = "Terraform_ENV"
    external_id  = "GitHubAction"
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }

  registry {
    password = data.aws_ecr_authorization_token.token.password
    url      = "oci://${var.default_helm_repo}"
    username = local.ecr_user
  }
}


data "aws_ecr_authorization_token" "token" {
}

locals {
  ecr_user = "AWS"
}
