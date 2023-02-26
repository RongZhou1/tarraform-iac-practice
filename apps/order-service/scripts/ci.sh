#!/bin/bash

BASE_DIR=$(git rev-parse --show-toplevel)
cd "$BASE_DIR/apps/order-service" || return

./gradlew clean build
