terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = "kind-kind"
}

provider "null" {
}

provider "kubectl" {
  load_config_file = true
  config_path = "~/.kube/config"
  config_context_cluster = "kind-kind"
}
