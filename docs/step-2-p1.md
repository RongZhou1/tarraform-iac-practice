部署 mysqldb
--

- 部署

  - 引入自建的 terraform module [mysql](../terraform/module/mysql)，可以根据给定参数在集群中创建 mysql 数据库。
  - 使用 terraform 定义 [db](./scripts/db)，部署应用程序时使用
    > 该脚本作为练习临时使用，因此没有定义在 `terraform` 文件夹下，之后的联系中不会这样单独使用。
  - 将期望使用的密码设置为环境变量，如果不在环境变量中设置，terraform 会要求你运行时输入
    ```bash
      $ export TF_VAR_dbpassword=[这里请你自定义]
    ```
  - 运行以下脚本

    ```bash
    $ cd $(git rev-parse --show-toplevel)
    $ cd docs/scripts/db
    $ terraform init
    $ terraform apply --auto-approve
    ```

- 清理

    ```bash
    $ cd $(git rev-parse --show-toplevel)
    $ cd docs/scripts/db
    $ terraform destroy --auto-approve
    ```