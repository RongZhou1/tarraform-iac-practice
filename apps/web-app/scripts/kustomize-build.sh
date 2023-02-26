#!/bin/bash

BASE_DIR=$(git rev-parse --show-toplevel)

cd "$BASE_DIR" || return

if [ $# -eq 0 ]; then
  echo "No DEPLOY_TO arguments exist"
  echo "DEPLOY_TO: [kind-local/kind-stable]"
  exit 1
else
  DEPLOY_TO=$1
  SERVICE_NAME="web-app"

  if [ "$DEPLOY_TO" == "kind-local" ]; then
    VERSION="latest"
    IMAGE="$SERVICE_NAME:$VERSION"
  else
    VERSION="sha-$(git rev-parse --short HEAD)"
    IMAGE="ghcr.io/rongzhou1/$SERVICE_NAME:$VERSION"
  fi
  OVERLAY_PATH="./apps/$SERVICE_NAME/k8s/overlays/$DEPLOY_TO"
  MANIFEST_PATH="./k8sbuild/$DEPLOY_TO/$SERVICE_NAME"

  export SERVICE_NAME=$SERVICE_NAME
  export VERSION=$VERSION
  export IMAGE_NAME=$IMAGE
  export IMAGE_PULL_SECRET="ghcr-login-secret"

  mkdir -p $MANIFEST_PATH
  kubectl kustomize "$OVERLAY_PATH" | envsubst >|"$MANIFEST_PATH/k8s.yaml"
fi
