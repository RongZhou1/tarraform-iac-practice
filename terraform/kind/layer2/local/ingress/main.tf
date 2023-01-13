locals {
  apps        = {
    book_service = "book-service"
  }
  paths = {
    book_service = "/${var.environment}/api/${local.apps.book_service}"
  }
}

resource "kubernetes_ingress_v1" "nginx-ingress" {
  wait_for_load_balancer = false
  metadata {
    name        = "nginx-ingress"
    namespace   = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/$2"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<EOF
        rewrite ^(/${var.environment}/.*/(swagger-ui.html|swagger-ui|swagger-ui/.*|api-doc|api-doc/.*))$ $1 break;
      EOF
    }
  }
  spec {
    rule {
      http {
        path {
          path      = "${local.paths.book_service}(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = local.apps.book_service
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}