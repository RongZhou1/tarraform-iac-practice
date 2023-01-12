Step 1， 搭建本地K8S集群
--

- [x] 环境准备，软件安装
- [x] 使用 Kind 创建集群
- [x] 使用 Terraform 管理集群，熟悉其工作流程

### 1.1 环境准备，软件安装

后面的任务需要使用以下软件

- [kind](https://registry.terraform.io/providers/kyma-incubator/kind/0.0.11)，K8S的本地集群工具，类似的还有 [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)，Kubernetes 命令行工具
- [Terraform](https://www.terraform.io/)，基础设施自动化编排工具

可以通过执行该文件 [setup_macos.sh](./../scripts/setup_macos.sh) 安装或官网下载安装。

#### 验收条件

```bash
$ kind --version
kind version xxx

$ kubectl version --short
Client Version: xxx
Kustomize Version: xxx
Server Version: xxx

$ terraform -v
Terraform xxx
```

### 1.2 使用 Kind 创建集群

参考官方文档，使用 `kind` 完成以下任务

- 创建集群
- 查看集群
- 删除集群


#### 验收条件

```bash
$ kubectl cluster-info --context kind-kind

Kubernetes control plane is running at https://127.0.0.1:52096
CoreDNS is running at https://127.0.0.1:52096/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

#### 打扫战场

```bash
# 删除集群
$ kind delete cluster
Deleting cluster "kind" ...
# 确认没有正在运行的集群
$ kind get clusters
No kind clusters found.
```

### 1.3 使用 Terraform 管理集群，熟悉其工作流程

尽管使用 kind 命令可以很容易创建集群，我们期望你通过该任务能够熟悉 Terraform 的基本命令。

- 在目录 [terraform/kind/layer0](../terraform/kind/layer0) 下创建 `main.tf`
- 参考 [kind provider](https://registry.terraform.io/providers/justenwalker/kind/latest) 编写脚本，创建名为 `kind` 的 kind 集群
- 练习使用命令，观察输出和 tfstate 文件，并理解含义
  - terraform init
  - terraform plan
  - terraform apply
  - terraform destroy
- 阅读官方文档，了解更多

#### 验收条件

1. 使用 Terraform 创建集群

```bash
$ kubectl cluster-info --context kind-kind

Kubernetes control plane is running at https://127.0.0.1:52096
CoreDNS is running at https://127.0.0.1:52096/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

2. 使用 Terraform 销毁集群

```bash
$  kubectl cluster-info --context kind-kind
error: context "kind-kind" does not exist
```