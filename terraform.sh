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
  echo
  echo "Use the following command to ssh into the management node:"
  echo
  terraform output ssh
  echo
fi
