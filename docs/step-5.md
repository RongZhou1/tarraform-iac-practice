Step 5. 创建 Ingress 控制器，配置出口路由
--

- [ ] 使用 Terraform 创建和管理 Ingress 控制器
- [ ] 配置出口路由


本例使用本地环境模拟服务的运行环境，屏蔽了很多网络很DNS配置的复杂性。
根据需求，两套环境使用相同的本地域名，通过不同的路径访问不同环境，这里采用 Kubernetes 的 [Ingress](https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/) 资源来实现。

  ```
  /local/api/xxx   -> kind-local 环境的某服务
  /stable/api/xxx  -> kind-stable 环境的某服务
  ```

### 5.1 使用 Terraform 创建和管理 Ingress 控制器

- 执行 `git rebase step-5`
- 阅读文档，理解 [Ingress](https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/)，[Ingress Controller](https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress-controllers/) 的基本概念
  本例选用 Nginx Ingress 作为 Ingress 控制器
- 配置支持 Nginx Ingress 的 Kind 集群，参考 [Kind文档](https://kind.sigs.k8s.io/docs/user/ingress/)
  - 参照文档修改文件 [layer0/main.tf](../terraform/kind/layer0/main.tf) 中的 `nodes` 配置
  - 使用命令 `terraform destroy`, `terraform apply` 重建集群
- 在 layer1 安装 Nginx Ingress 控制器，它是集群共享的，因此不同命名空间共用使用
  代码已经写好，安装应用即可
  > 由于该实现有瑕疵，资源执行顺序随机，有可能出现资源依赖等待问题，若超时未成功，重新执行 terraform apply 即可。

#### 验收条件

```bash
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.96.144.180   <none>        80:32619/TCP,443:30275/TCP   16m
ingress-nginx-controller-admission   ClusterIP   10.96.44.94     <none>        443/TCP                      16m

```

### 5.2 配置出口路由

根据需求，需要改写请求的访问路径，去掉前缀 /local/api/book-service 并将后面的路径导向 kind-local 环境的 book-service 服务

- 阅读 [文档示例](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)
- 已完成 ingress 对 book-service 的路由，见文件 [ingress/main.tf](../terraform/kind/layer2/local/ingress)，
  - 完成 web-app 和 order-service 的路由配置，使能满足需求
  - 请在上级 main.tf 文件中加载该模块，将应用在 k8s 中的域名作为参数传入 ingress 模块
- 由于集群完全重建，请重新安装 layer2 的基础设施
- 使用 kubectl 重新部署应用程序

#### 验收条件

curl http://localhost/local/api/web-app/books 返回正确的 json

curl http://localhost/local/api/web-app/orders 返回正确的 json
