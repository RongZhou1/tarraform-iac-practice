locals {
  app_name = "order-service"
  db_name  = replace(local.app_name, "-", "_")
}

resource "kubernetes_secret" "order-service" {
  metadata {
    name      = "${local.app_name}-terraform"
    namespace = var.namespace
  }

  data = {
    MYSQL_DB_HOST     = var.db_host
    MYSQL_DB_PORT     = var.db_port
    MYSQL_DB_USER     = var.db_user
    MYSQL_DB_PASSWORD = var.db_password
  }
}

resource "kubernetes_config_map" "order-service" {
  metadata {
    name      = "${local.app_name}-terraform"
    namespace = var.namespace
  }
  data = {
    DB_NAME = local.db_name
  }
}

module "create-db-job" {
  source    = "../../../../terraform/module/mysql-create-db"
  namespace = var.namespace

  host     = var.db_host
  password = var.db_password
  port     = var.db_port
  user     = var.db_user
  db_name  = local.db_name
}

output "service-name" {
  value = local.app_name
}