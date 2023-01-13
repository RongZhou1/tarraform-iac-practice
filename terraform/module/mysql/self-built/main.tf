resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_=+:?"
}

resource "kubernetes_secret" "database_secret" {
  metadata {
    name      = "mysql-credentials"
    namespace = var.namespace
  }

  data = {
    rootpasswd = var.db_password == null ? random_password.password.result : var.db_password
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
    labels    = {
      managed_by = "terraform"
      app        = "mysqldb"
      version    = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "mysqldb"
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = "mysqldb"
          version = "v1"
        }
      }

      spec {
        container {
          name  = "mysqldb"
          image = "mysql:8.0.31"

          resources {
            requests = {
              memory = "500Mi"
            }
            limits = {
              memory = "1000Mi"
            }
          }
          port {
            container_port = 3306
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"

            value_from {
              secret_key_ref {
                name = "mysql-credentials"
                key  = "rootpasswd"
              }
            }
          }

          args = ["--default-authentication-plugin", "mysql_native_password"]

          volume_mount {
            name       = "var-lib-mysql"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "var-lib-mysql"

          empty_dir {
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name      = "mysqldb"
    namespace = var.namespace
    labels    = {
      managed_by = "terraform"
      app        = "mysqldb"
      service    = "mysqldb"
    }
  }

  spec {
    port {
      port = 3306
      name = "tcp"
    }

    selector = {
      app = "mysqldb"
    }
  }
}
