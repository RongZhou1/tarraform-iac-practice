#!/bin/bash
set -ex

BASE_DIR=$(git rev-parse --show-toplevel)

cd "$BASE_DIR" || return

SERVICE_NAME="order-service"
VERSION="latest"

cd "apps/$SERVICE_NAME" || return

IMAGE_NAME="$SERVICE_NAME:$VERSION"
./gradlew bootJar
docker build -t "$IMAGE_NAME" .

kind load docker-image "$IMAGE_NAME" "$IMAGE_NAME"
