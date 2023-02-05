创建数据库
---

我们同样希望采用 IaC 的方式完成这一步。


- 引入自建的 terraform module [mysql-create-db](../terraform/module/mysql-create-db)，可以根据给定参数在 mysql 数据库中创建数据库。
  - 使用 terraform 定义 create db job，在文件 [main.tf](./scripts/db/main.tf) 中添加如下代码

    ```terraform
    module "create-db-book-service" {
      source = "../../../terraform/module/mysql-create-db"

      db_name   = "book_service"
      namespace = local.namespace
      host      = module.mysqldb.mysql_db_host
      password  = module.mysqldb.mysql_db_password
      port      = module.mysqldb.mysql_db_port
      user      = module.mysqldb.mysql_db_user
    }
    ```

- 运行以下脚本

  ```bash
  $ terraform init --upgrade
  $ terraform plan
  $ terraform apply --auto-approve
  ```