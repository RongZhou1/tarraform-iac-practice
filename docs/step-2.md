Step 2， 编写K8S配置文件，部署应用程序到集群
--

- [x] 使用 Kubectl 创建部署
- [x] 为应用程序创建 Service 资源
- [x] 部署所有应用程序使可访问


### 2.1 使用 Kubectl 创建部署

- 执行 `git rebase origin/step-2`
- 阅读[官方文档](https://kubernetes.io/zh-cn/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)，了解基本概念
- 部署 `book-service`
  - 打包创建容器镜像

    > 向 K8S 部署应用程序时，需要指定其容器镜像以，因此需要先构建镜像。

    执行以下脚本创建本地镜像 `book-service:latest` (需要 Java17+) ，并加载到 kind 集群中.

    ```bash
    $ cd ./apps/book-service
    $ ./scripts/local-build.sh
    ```
  - 创建部署
    ```bash
    # 创建
    $ kubectl create deployment book-service --image=book-service:latest
    # 查看部署结果
    $ kubectl get po
    NAME                            READY   STATUS         RESTARTS   AGE
    book-service-7db45cff75-d4c7d   0/1     ErrImagePull   0          73s
    ```
  - 使用配置文件创建部署
    > 上面的部署失败了，原因是 `ErrImagePull`，因为默认从远端镜像仓库拉取镜像。我们定义配置文件，设置参数 `imagePullPolicy: Never` 使可以从本地拉取镜像。
    >
    > 此外，观察应用程序配置文件 [application.yml](../apps/book-service/src/main/resources/application.yml) 需要数据库的配置参数，因此，需要另做两件事情：
    >
    > 1. 创建基础设施 mysql 数据库实例
    > 2. 为应用程序创建自己的数据库，本例中希望创建名为 `book_service` 的数据库
    > 3. 微应用程序配置数据库参数

    - [部署 mysqldb](./step-2-p1.md)
    - [创建数据库 `book_service`](./step-2-p2.md)
    - 定义部署配置 [deployment.yaml](../apps/book-service/k8s/deployment.yaml)，其中已经设置了拉取规则和数据库参数
    - 部署应用程序
    ```bash
      $ kubectl delete deployment book-service # 之前已经创建失败过，需要删除才能重新创建
      $ cd $(git rev-parse --show-toplevel)
      $ cd apps/book-service
      $ kubectl apply -f k8s/deployment.yaml
      $ kubectl get deployment
    ```

#### 验收条件

执行端口转发，使外部可以访问到集群内的应用程序：

```bash
$ lsof -i:8090 # 确认当前端口未被其它进程使用
$ kubectl port-forward deployment/book-service 8090:8080
```

访问 http://localhost:8090/actuator 可以看到如下信息
```json
{
    "_links": {
        "self": {
            "href": "http://localhost:8090/actuator",
            "templated": false
        },
        "health": {
            "href": "http://localhost:8090/actuator/health",
            "templated": false
        },
        "health-path": {
            "href": "http://localhost:8090/actuator/health/{*path}",
            "templated": true
        }
    }
}
```


#### 打扫战场

```bash
$ kubectl delete deployment book-service
```

### 2.2 为应用程序创建 Service 资源

由于微服务之间需要通信，因此只部署应用程序是不够的，还需要创建 Service 资源使服务能够被发现并被其他服务访问。

- 阅读 [官方文档](https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/)
- 定义 Service [service.yaml](../apps/book-service/k8s/service.yaml)
- 创建 Service
  ```bash
  $ cd $(git rev-parse --show-toplevel)
  $ cd apps/book-service
  $ kubectl apply -f k8s/service.yaml
  ```

#### 验收条件

执行端口转发，使外部可以通过Service访问到集群内的应用程序：

```bash
$ lsof -i:8090 # 确认当前端口未被其它进程使用
$ kubectl port-forward service/book-service 8090:80
```

访问 http://localhost:8090/actuator 可以看到正确的JSON

#### 打扫战场

```bash
$ kubectl delete service book-service
```

### 2.3 部署所有应用程序使可访问

- 使用 2.1 中的步骤部署 order-service，并保证其可访问
  > 参考 order-service 的配置文件 [application.yml](../apps/order-service/src/main/resources/application.yml)
- 使用 2.1 中的部署 web-application，但有所不同：
  > 参考 web-app 的配置文件 [application.yml](../apps/web-app/src/main/resources/application.yml)
  - 它不依赖数据库，因此不需要配置数据库参数
  - 它依赖服务 order-service 和 book-service，需要配置两个服务的地址。由于服务在同一集群，可以使用集群内的服务名
    - book-service: book-service
    - order-service: order-service

#### 验收条件

对服务 web-application 执行端口转发，使外部可以通过Service访问到集群内的应用程序：

```bash
$ lsof -i:8090 # 确认当前端口未被其它进程使用
$ kubectl port-forward service/web-app 8090:80
```

访问 curl http://localhost:8090/books 可以看到如下信息，确认与 `book-service` 通信正常

```json
{
    "data": [],
    "total": 0
}
```

curl http://localhost:8090/orders， 确认与 `order-service` 通信正常

```json
{
    "data": [],
    "total": 0
}
```