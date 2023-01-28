module "nginx-ingress" {
  source = "./nginx-ingress"
}

module "argocd" {
  source = "./argocd"
  
  argo_namespace = "argocd"
}