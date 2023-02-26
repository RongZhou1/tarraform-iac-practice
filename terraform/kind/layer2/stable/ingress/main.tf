locals {
  apps        = {
    book_service = "book-service"
    order_service ="order-service"
    web_app = "web-app"
  }
  paths = {
    book_service = "/${var.environment}/api/${local.apps.book_service}"
    order_service = "/${var.environment}/api/${local.apps.order_service}"
    web_app = "/${var.environment}/api/${local.apps.web_app}"
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
        path {
          path      = "${local.paths.order_service}(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = local.apps.order_service
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "${local.paths.web_app}(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = local.apps.web_app
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