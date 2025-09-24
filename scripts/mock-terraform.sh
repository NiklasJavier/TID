#!/usr/bin/env bash
# mock-terraform.sh -- lightweight Terraform replacement for CI CLI tests
# This helper mimics a subset of terraform behaviour so runner.sh can be
# exercised without talking to real providers.
set -euo pipefail

printf '[mock-terraform] %s\n' "$*"

if [ "$#" -eq 0 ]; then
  exit 0
fi

case "$1" in
  init)
    mkdir -p .terraform
    # Simulate the lock file that terraform would create
    touch .terraform.lock.hcl
    ;;
  plan|apply|destroy|validate|fmt)
    # Nothing to do — runner.sh only needs a successful exit status
    ;;
  *)
    # Accept other commands without side effects
    ;;
esac
