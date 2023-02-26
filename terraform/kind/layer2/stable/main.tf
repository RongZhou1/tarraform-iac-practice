locals {
  namespace   = "kind-stable"
  platform   = "kind"
}

variable "db_password" {}


# 使用 provider - kubernetes_namespace 创建名为 local.namespece 的命名空间
# Task 3.1

module "mysqldb" {
  depends_on = []  # Task 3.2

  source = "../../../module/mysql"

  platform    = local.platform
  namespace   = local.namespace
  db_password = var.db_password
}

# 使用 module 调用 book-service 中的 terraform 资源
# Task 3.3