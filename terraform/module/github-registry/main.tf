data "template_file" "docker_config_script" {
  template = "${file("${path.module}/dockerconfig.json")}"
  vars     = {
    auth = base64encode("${var.github_user}:${var.github_token}")
  }
}

resource "kubernetes_secret" "ghcr-login-secret" {
  metadata {
    name      = "ghcr-login-secret"
    namespace = var.namespace
  }
  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = "${data.template_file.docker_config_script.rendered}"
  }
}