locals {
  command = "CREATE DATABASE IF NOT EXISTS ${var.db_name};"
}
resource "kubernetes_job" "mysql-create-db" {
  metadata {
    name      = "create-database"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        name = "create-database"
      }
      spec {
        container {
          name    = "create-database"
          image   = "imega/mysql-client:latest"
          command = [
            "mysql",
            "-u${var.user}", "--password=${var.password}",
            "-h${var.host}", "-P${var.port}",
            "--execute=${local.command}"
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 10
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}
