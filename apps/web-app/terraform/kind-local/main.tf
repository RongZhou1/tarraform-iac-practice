locals {
  app_name = "web-app"
  db_name  = replace(local.app_name, "-", "_")
}

resource "kubernetes_config_map" "web-app" {
  metadata {
    name      = "${local.app_name}-terraform"
    namespace = var.namespace
  }
  data = {
    BOOK_SERVICE_URL  = var.book_service_url
    ORDER_SERVICE_URL = var.order_service_url
  }
}

