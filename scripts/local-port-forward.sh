#!/bin/bash

echo "port forward argocd 30443:443"
kubectl port-forward service/argocd-server 30443:443 -n argocd 1>/dev/null 2> argocd-port-forward.log &
