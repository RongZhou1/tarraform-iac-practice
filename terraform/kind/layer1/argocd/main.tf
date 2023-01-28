variable "argo_namespace" {}

terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

module "argocd" {
  source = "lablabs/argocd/helm"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  self_managed = false

  helm_release_name = "argocd"
  namespace         = var.argo_namespace

  helm_timeout = 480
  helm_wait    = true
}