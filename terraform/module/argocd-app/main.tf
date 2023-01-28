resource "kubernetes_manifest" "argo-application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata   = {
      name      = var.name
      namespace = var.argocd_namespace
      labels    = var.labels
    }
    spec = {
      project = var.project
      source  = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.path
      }
      destination = {
        server    = var.destination_server
        namespace = var.destination_namespace
      }
      ignoreDifferences = var.ignore_differences
      syncPolicy        = {
        automated = {
          prune    = var.automated_prune
          selfHeal = var.automated_self_heal
        }
        syncOptions = concat(var.sync_options, [
          var.sync_option_validate ? "Validate=true" : "Validate=false",
          var.sync_option_create_namespace ? "CreateNamespace=true" : "CreateNamespace=false",
        ])
        retry = {
          limit   = var.retry_limit
          backoff = {
            duration    = var.retry_backoff_duration
            factor      = var.retry_backoff_factor
            maxDuration = var.retry_backoff_max_duration
          }
        }
      }
      ignoreDifferences = var.ignore_differences
    }
  }
}