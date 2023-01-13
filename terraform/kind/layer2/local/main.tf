locals {
  namespace   = "kind-local"
  platform   = "kind"
}

variable "db_password" {}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

module "mysqldb" {
  depends_on = [kubernetes_namespace.namespace]

  source = "../../../module/mysql"

  platform    = local.platform
  namespace   = local.namespace
  db_password = var.db_password
}

module "book-service" {
  depends_on = [module.mysqldb]

  source = "../../../../apps/book-service/terraform/kind-local"
  namespace = local.namespace
  
  db_host = module.mysqldb.mysql_db_host
  db_password = module.mysqldb.mysql_db_password
  db_port = module.mysqldb.mysql_db_port
  db_user = module.mysqldb.mysql_db_user
}