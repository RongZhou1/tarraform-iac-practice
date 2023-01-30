# Terraform IaC practice

------
基于本地环境的 Terraform IaC 练习。

本案例以简单的微服务模拟应用程序代码，以本地集群模拟实际集群环境，
step by step 学习基于 `Terraform`、 `ArgoCD` 的 K8S 集群下搭建自动化、可重复执行、易于管理的不可变基础设施的基本思路和方法。

在掌握方法后，可自行利用云资源进一步学习，以覆盖本案例未涉及到的内容，如：Terraform 的远程状态管理，云服务的 Terraform Provider 等。

## 内容覆盖

- 使用 Kubernetes 构建软件服务
- 使用 Terraform 构建和管理基础设施
- CI/CD 和 GitOps

## 基础环境

- Mac OS
- docker 运行环境

## 模拟需求

### 应用程序信息

模拟应用程序提供了图书下单服务，由一个 Web Application 和两个后端 Service 组成，服务间关系如下：

  ```terraform
  Web Application
      │
      ├───── 图书信息 ───── BookService
      │
      └───── 订单信息 ───── OrderService
  ```

### 部署要求

- 使用IaC实践部署两套环境
  - kind-local
    - 模拟开发环境，运行调试优先，方便开发和验证
    - 所有服务都可以访问
    - 所有服务的API DOC 可以访问
    - 方便开发，可以使用环境变量设定密码
    - 使用本地打包的 image 部署服务
  - kind-stable
    - 模拟UAT环境
    - 只有BFF服务可以访问，后端服务不能直接访问
    - 所有服务的API DOC 可以访问
    - 密码动态生成
    - 只能部署 image registry 里经过验证的image
- 两套环境的出口路由规则

  ```
  /local/api/xxx   -> kind-local 环境的某服务
  /stable/api/xxx  -> kind-stable 环境的某服务
  ```

## 使用方法

检出分支 step-0 `git checkout step-0`，根据 README 中的需求分析和任务清单进行练习即可。


