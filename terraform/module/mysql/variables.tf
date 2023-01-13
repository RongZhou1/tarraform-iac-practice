locals {
  is_selfbuilt = var.platform == "kind" || var.platform == "minikube"
}

variable "platform" {}
variable "namespace" {}
variable "db_password" {
  type = string
  default = null
}