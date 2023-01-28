resource "kubernetes_manifest" "argo-repository-secret" {
  computed_fields = ["stringData"]
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata   = {
      name      = var.name
      namespace = var.argocd_namespace
      labels    = merge({
        "argocd.argoproj.io/secret-type" = "repository"
      }, var.labels)
    }
    type = "Opaque"
    stringData = {
      "url"           = var.repo_url
      "username"      = var.repo_username
      "password"      = var.repo_password
      "sshPrivateKey" = var.repo_ssh_private_key
    }
  }
}