resource "kind_cluster" "kind-cluster" {
  name = "kind"
  config = <<-EOF
    apiVersion: kind.x-k8s.io/v1alpha4
    kind: Cluster
    nodes:
      - role: control-plane
        kubeadmConfigPatches:
        - |
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        extraPortMappings:
        - containerPort: 80
          hostPort: 80
          protocol: TCP
        - containerPort: 443
          hostPort: 443
          protocol: TCP
EOF
}

