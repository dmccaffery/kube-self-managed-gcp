#! /usr/bin/env sh

set -eu

tfargs=${@:-"apply"}

if test -f "backend.tf"; then
  terraform init
  terraform ${tfargs} || true
else
  terraform init
  terraform ${tfargs}
  terraform init -force-copy
  rm -f terraform.tfstate*
fi

if test "${tfargs#*destroy}" != "$tfargs"; then
  rm -f backend.tf 2>/dev/null || true
  rm -f .terraform/terraform.tfstate 2>/dev/null || true
  rm -f errored.tfstate 2>/dev/null || true
else
  CLR_BRIGHT_GREEN='\033[1;32m'    # BRIGHT GREEN
  CLR_BRIGHT_YELLOW='\033[1;33m'   # BRIGHT YELLOW
  CLR_CLEAR='\033[0m'              # DEFAULT COLOR
  echo
  echo "${CLR_BRIGHT_YELLOW}Use the following command to ssh into the management node:"
  echo "${CLR_BRIGHT_GREEN}"
  terraform output ssh
  echo "${CLR_CLEAR}"
  echo
  echo "${CLR_BRIGHT_YELLOW}Use the following command to collect the kube config (after install kubernetes, of course):"
  echo "${CLR_BRIGHT_GREEN}"
  terraform output kube_config
  echo "${CLR_CLEAR}"
fi
