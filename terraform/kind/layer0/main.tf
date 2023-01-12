resource "kind_cluster" "kind-cluster" {
  name = "kind"
  config = <<-EOF
    apiVersion: kind.x-k8s.io/v1alpha4
    kind: Cluster
    nodes:
      - role: control-plane
    EOF
}
