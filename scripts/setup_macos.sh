#!/usr/bin/env bash


echo "install kind"

FILE=/usr/local/bin/kind
if test -f "$FILE"; then
    echo "$FILE exists."
else
    brew install kind
fi


echo "install kubectl"

FILE=/usr/local/bin/kubectl
if test -f "$FILE"; then
  echo "$FILE exists."
else
  brew install kubectl
fi


echo "install terraform"

FILE=/usr/local/bin/terraform
if test -f "$FILE"; then
  echo "$FILE exists."
else
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
fi
