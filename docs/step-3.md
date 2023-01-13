Step 3. 使用 Terraform 管理应用程序所需的两套基础设施
--

- [x] 创建两套环境
- [x] 为不同环境创建数据库基础设施
- [x] 为不同环境创建开发团队自行管理的基础设施配置文件
- [ ] 完成其他应用服务的基础设施搭建


在实际场景中，多套环境可能使用多个集群，也可能某些环境部署在同一集群，使用不同的命名空间。

我们这里用两个不同的命名空间来区分这些环境
- kind-local
- kind-stable

多套环境需要不同的配置，其来源会有所不同，我们采用下述惯例：
- 有些配置来源于不同环境的基础设施，我们将它们放到名为 `${SERVICE_NAME}-terraform` 的配置文件中
- 有些来源于不同环境的应用配置，我们将它们放到名为 `${SERVICE_NAME}` 的配置文件中

### 3.1 创建两套环境

- 在 [terraform/kind](../terraform/kind) 文件夹下创建 `layer2/local` 和 `layer2/stable` 目录，用来描述不同环境的基础设置。
- 在 [main.tf](../terraform/kind/layer2/local/main.tf) 中编写代码，使用 provider - [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) 创建命名空间。
- 执行 `terraform init`, `terraform apply` 应用配置创建命名空间

#### 验收条件

```bash
$ kubectl get namespaces
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   22h
kind-local           Active   24m
kind-stable          Active   24m
...
```

### 3.2 为不同环境创建数据库基础设施

- 修改 [main.tf](../terraform/kind/layer2/local/main.tf)  中 `module.mysqldb.dependOn`，将 3.1 中创建的资源作为依赖填入，以保证资源的创建顺序
- 执行 `terraform init`, `terraform apply` 创建数据库


### 3.3 为不同环境创建开发团队自行管理的基础设施配置文件

在数据库就绪后，开发团队需要使用相关输出支持应用程序的开发运行，本例中有两件事：
1. 应用数据库实例的连接信息创建应用需要使用的数据库
2. 应用创建的数据库的链接信息连接数据库，运行应用程序

由于这些工作的职责主要在应用开发过程中，由开发人员自行配置管理，因此将这部分管理放在应用程序路径下。

- 查看并理解位于应用程序路径下的 [terraform/kind-local/main.tf](../apps/book-service/terraform/kind-local/main.tf)
- 在 [kind/layer2/local/main.tf](../terraform/kind/layer2/local/main.tf) 中，编写代码调用上一步中构建的资源声明。
- 执行 `terraform init`, `terraform apply` 应用资源更新

#### 验收条件

```bash
$ kubectl get cm book-service-terraform -o jsonpath='{.data}' -n kind-local
{"DB_NAME":"book_service"}%
$ kkubectl get secret book-service-terraform -o jsonpath='{.data.MYSQL_DB_PASSWORD}' -n kind-local | base64 -d && echo
******
```

### 3.4 完成其他应用服务的基础设施搭建

- 参照 3.3 中的步骤完成 order-service 的基础设施构建
- 参照 3.3 中的步骤完成 web-app 的基础设施构建，注意：
  - 它不依赖数据库，因此不需要构建数据库相关资源
  - 它依赖服务 order-service 和 book-service，需要在 `configmap` 中配置两个服务的地址

### 清理


```bash
$ cd $(git rev-parse --show-toplevel)
$ cd terraform/kind/layer2/local
$ terraform destroy
```