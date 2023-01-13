variable "dbpassword" {}

locals {
  namespace = "default"
}

module "mysqldb" {
  source = "../../../terraform/module/mysql"
  namespace = local.namespace
  platform = "kind"
  db_password = var.dbpassword
}

resource "kubernetes_secret" "db-secret" {
  
  metadata {
    name      = "db-secret"
    namespace = local.namespace
  }

  data = {
    MYSQL_DB_HOST     = module.mysqldb.mysql_db_host
    MYSQL_DB_PORT     = module.mysqldb.mysql_db_port
    MYSQL_DB_USER     = module.mysqldb.mysql_db_user
    MYSQL_DB_PASSWORD = module.mysqldb.mysql_db_password
  }
}
