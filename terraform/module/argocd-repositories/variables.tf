variable "argocd_namespace" {
  type        = string
  description = "The name of the target ArgoCD Namespace"
}
variable "repo_url" {
  type = string
}
variable "repo_username" {
  type = string
}
variable "repo_password" {
  type = string
}
variable "repo_ssh_private_key" {
  type    = string
  default = null
}
variable "name" {
  type = string
}
variable "labels" {
  type        = map(string)
  description = ""
  default     = {}
}