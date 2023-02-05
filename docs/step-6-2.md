Step 6. GitOps 持续部署
--
## 6-2 部署 ArgoCD，实现自动化部署

- [ ] 在集群安装运行 ArgoCD
- [ ] 在 ArgoCD 中创建 Application，实现应用程序的自动化部署

### 6-2.1 在集群安装运行 ArgoCD

- 执行 `git rebase origin/step-6-2`
- 参考官方文档，理解 [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) 的基本概念
- 在 layer1 安装 ArgoCD，Terraform 配置文件已经写好，安装应用即可


#### 验收条件

- 端口转发 ArgoCD 服务到 30443
  ```bash
  $ kubectl port-forward service/argocd-server 30443:443 -n argocd 1>/dev/null 2> argocd-port-forward.log &
  ```
- 浏览器打开 https://localhost:30443，看到 ArgoCD 登录界面
- 使用密码成功登录管理界面
  ```bash
  $  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

### 6-2.2 在 ArgoCD 中创建 Application，实现应用程序的自动化部署

- 阅读已完成编写的 terraform module [argocd-app](../terraform/module/argocd-app) 和
  [argocd-repositories](../terraform/module/argocd-repositories)，
  其功能分别为 `创建 ArgoCD 的 Application` 和 `创建用于访问 Git Repository 登录凭证的 Secret`，
  如果仓库是私有仓库，则需要用到第二个 module。
- 如果代码仓库是私有的，在 `layer1` 导入 module `argocd-repositories` 并完成配置，注意秘钥不要写到代码里，可以通过环境变量进行配置
  (可参考 6-1.2 中的写法 `export TF_VAR_xxx=xxx`)
- 在 `layer2/local` 下编写代码，导入 module `argocd-app` 完成 web-app 的配置,
  创建名为 `web-app-local-application` 的 Application，
  参考文档 [Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications)，
  参考`验收条件-local`完成验证
- 在 `layer2/stable` 下编写代码，导入 module `argocd-app` 完成 web-app 的配置，
  创建名为 `web-app-stable-application` 的 Application，参考`验收条件-stable`完成验证
- 完成其他应用程序的 Terraform 自动化部署脚本并部署，公共部分可以在 `layer2/${env}` 下提取公共模块，参考`验收条件-apps`完成验证

#### 验收条件-local

- 登录 ArgoCD UI 面板，查看 Applications，存在 `web-app-local-application`，且状态为 `healthy`
- 修改应用程序代码，如修改文件 [BookController](../apps/web-app/src/main/java/org/example/looam/web/controller/BookController.java)，添加以下代码
  ```
  @GetMapping("/first-ten")
  public List<BookDTO> findFirstTen(
      @RequestParam(required = false) String searchKey) {
    return bookService.findPage(searchKey, 1, 10).data();
  }
  ```
  执行本地打包脚本
  ```bash
  $ cd ./apps/web-app
  $ ./scripts/local-build.sh
    ```
- 观察 `web-app-local-application` 下的资源变化，等待部署成功且状态再次变成 `healthy`
- curl http://localhost/local/api/web-app/books/first-ten ，能够响应并返回空数组


#### 验收条件-stable

- 登录 ArgoCD UI 面板，查看 Applications，存在 `web-app-stable-application`，且状态为 `healthy`
- push 在上一步已修改的代码到远端代码仓库，等待 CI 执行并成功
- 观察 `web-app-stable-application` 下的资源变化，等待部署成功且状态再次变成 `healthy`
- curl http://localhost/stable/api/web-app/books/first-ten ，能够响应并返回空数组

#### 验收条件-apps

- 登录 ArgoCD UI 面板，查看 Applications，存在以下6个 Apps，且状态均为 `healthy`
  - web-app-local-application
  - book-service-local-application
  - order-service-local-application
  - web-app-stable-application
  - book-service-stable-application
  - order-service-stable-application
