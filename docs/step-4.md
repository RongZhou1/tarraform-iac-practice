Step 4. 部署应用程序到两套环境
--

- [ ] 资源声明文件中统一使用管理配置文件
- [ ] 使用 Kustomize 管理 Kubernetes 对象
- [ ] 完成其他应用服务的更新


在实际场景中，多套环境可能使用多个集群，也可能某些环境部署在同一集群，使用不同的命名空间。

我们这里用两个不同的命名空间来区分这些环境
- kind-local
- kind-stable

多套环境需要不同的配置，其来源会有所不同，我们采用下述惯例：
- 有些配置来源于不同环境的基础设施，我们将它们放到名为 `${SERVICE_NAME}-terraform` 的配置文件中
- 有些来源于不同环境的应用配置，我们将它们放到名为 `${SERVICE_NAME}` 的配置文件中
-
### 4.1 资源声明文件中统一使用管理配置文件
- 执行 `git rebase origin/step-4`
- 修改 Step 2 中 创建的 `deployment.yaml` 和 `service.yaml`
  - 统一使用 `${SERVICE_NAME}` 替换服务名称，之后可以通过 `envsubst` 工具进行环境变量的替换
  - 添加 `version: ${VERSION}` 作为资源的 label
  - 使用以下代码替换原有的资源配置描述 `env` 和 `envFrom`，从而使用上一步构建的 `configmap` 和 `secret`

    ```yaml
      envFrom:
        - configMapRef:
            name: ${SERVICE_NAME}
            optional: true
        - configMapRef:
            name: ${SERVICE_NAME}-terraform
            optional: true
        - secretRef:
            name: ${SERVICE_NAME}
            optional: true
        - secretRef:
            name: ${SERVICE_NAME}-terraform
            optional: true
    ```

### 4.2 使用 Kustomize 管理 Kubernetes 对象

- 阅读 [官方文档](https://kubernetes.io/zh-cn/docs/tasks/manage-kubernetes-objects/kustomization/) 理解 Kustomize的应用场景，本案例主要使用它的 base 和 overlays 的功能
- 将 `deployment.yaml` 和 `service.yaml` 作为基准资源文件，放入 `base` 文件夹，并创建 `overlays` 文件夹和对应环境文件夹。
  - 目录结构如下：
    ```text
    k8s
    ├── base
    │     ├── deployment.yaml
    │     └── service.yaml
    └── overlays
          ├── kind-local
          └── kind-stable
    ```
  - 参考文档，在 base 和两个环境文件夹下创建 `kustomization.yaml` 文件，两个环境分别使用 `namespace` 为：
    - kind-local
    - kind-stable
  - 在不同环境下定义不同的镜像拉取策略，`kind-local` 仍使用本地拉取的方式，`kind-stable` 使用从远端拉取的方式。相关定义方式如下：
    > 远端拉取时，如果是私有仓库，需要鉴权，这一步我们还没有向远端上传镜像，也暂时不做验证。

    kind-local
      ```yaml
        containers:
          - name: ${SERVICE_NAME}
            image: ${IMAGE_NAME}
            imagePullPolicy: Never
      ```
    kind-stable
      ```yaml
        containers:
          - name: ${SERVICE_NAME}
            image: ${IMAGE_NAME}
            imagePullPolicy: IfNotPresent
        imagePullSecrets:
          - name: ${IMAGE_PULL_SECRET}
      ```

- 阅读并执行已定义好的脚本 [kustomize-build.sh](../apps/book-service/scripts/kustomize-build.sh)，构建不同环境的 k8s 配置。
  ```bash
  $ cd $(git rev-parse --show-toplevel)
  $ cd apps/book-service
  $ ./scripts/kustomize-build.sh kind-local
  $ ./scripts/kustomize-build.sh kind-stable
  ```
- 查看文件 `k8sbuild/kind-local/book-service/k8s.yaml`， `k8sbuild/kind-stable/book-service/k8s.yaml`
- 通过生成的文件在 kind-local 环境下部署应用
  ```bash
  $ cd $(git rev-parse --show-toplevel)
  $ kubectl apply -f k8sbuild/kind-local/book-service/k8s.yaml
  $ kubectl get svc -n kind-local
  ```

#### 验收条件

端口转发 namespace 为 kind-local 的 book-service 并验证 `curl http://localhost:8090/actuator`

```bash
$ lsof -i:8090 # 确认当前端口未被其它进程使用
$ kubectl port-forward service/book-service 8090:80 -n kind-local
```

### 4.3 完成其他应用服务的更新和部署

- 为服务 `order-service` 和 `web-app` 生成环境 `kind-local` 和 `kind-stable` 下的 k8s 资源描述文件
- 在环境 `kind-local` 下部署 为服务 `order-service` 和 `web-app`

#### 验收条件

- 在路径 `k8sbuild/kind-local` 和 `k8sbuild/kind-stable` 下生成个服务对应的资源描述文件

- 对服务 web-application 执行端口转发，使外部可以通过Service访问到集群内的应用程序：

  ```bash
  $ lsof -i:8090 # 确认当前端口未被其它进程使用
  $ kubectl port-forward service/web-app 8090:80 -n kind-local
  ```

  curl http://localhost:8090/books ，确认与 `book-service` 通信正常

  curl http://localhost:8090/orders ，确认与 `order-service` 通信正常
