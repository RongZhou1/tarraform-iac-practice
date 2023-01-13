terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "http" "ingress-nginx-kind-raw" {
  url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
}

data "kubectl_file_documents" "ingress-nginx-kind-yaml" {
  content = data.http.ingress-nginx-kind-raw.response_body
}

resource "kubectl_manifest" "ingress-nginx-controller" {
  count     = length(data.kubectl_file_documents.ingress-nginx-kind-yaml.documents)
  yaml_body = element(data.kubectl_file_documents.ingress-nginx-kind-yaml.documents, count.index)
  wait      = true
}

resource "null_resource" "wait-ingress-nginx" {
  triggers = {
    id = "wait-ingress-nginx"
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [kubectl_manifest.ingress-nginx-controller]
}