#!/usr/bin/env bash

# runner.sh für TID (Terraform Infrastructure Deployment)
# Unterstützt die Subcommands: list, up <service>, destroy <service>, plan <service>, help
# Dieses Skript geht davon aus, dass es aus dem Root des Repositories ausgeführt wird.

set -euo pipefail

REPO_ROOT="$(dirname "$(realpath "$0")")"
SERVICES_DIR="$REPO_ROOT/services"
SCRIPTS_DIR="$REPO_ROOT/scripts"
TERRAFORM_BIN="${TERRAFORM_BIN:-$REPO_ROOT/terraform}"

print_usage() {
  cat <<USAGE
Usage: ./runner.sh <subcommand> [arguments]

Subcommands:
  list                             Listet verfügbare Services (*.tfvars) und Skripte
  up <service> [terraform args]    Führt 'terraform apply' für den Service aus
  destroy <service> [args]         Führt 'terraform destroy' für den Service aus
  plan <service> [args]            Führt 'terraform plan' für den Service aus
  help                             Zeigt diese Hilfe an

Environment-Variablen (optional):
  HCLOUD_TOKEN, TF_VAR_hcloud_token     Hetzner API Token
  PROXMOX_TOKEN, TF_VAR_proxmox_token   Proxmox API Token
  TERRAFORM_BIN                         Alternativer Pfad/Name zu terraform
USAGE
}

require_terraform() {
  if ! command -v "$TERRAFORM_BIN" >/dev/null 2>&1; then
    echo "Error: Terraform nicht gefunden (TERRAFORM_BIN=$TERRAFORM_BIN)." >&2
    exit 1
  fi
}

ensure_repo_root() {
  if [ "$(pwd)" != "$REPO_ROOT" ]; then
    echo "Hinweis: Wechsel in Repository-Root $REPO_ROOT" >&2
    cd "$REPO_ROOT"
  fi
}

ensure_init() {
  ensure_repo_root
  local need_init=0

  if [ ! -d "$REPO_ROOT/.terraform" ]; then
    need_init=1
  elif [ ! -f "$REPO_ROOT/.terraform.lock.hcl" ]; then
    need_init=1
  fi

  if [ "$need_init" -eq 1 ]; then
    echo "Terraform nicht initialisiert – führe '$TERRAFORM_BIN init' aus..."
    "$TERRAFORM_BIN" init
  fi
}

list_services() {
  echo "Verfügbare Services (*.tfvars):"
  if [ -d "$SERVICES_DIR" ]; then
    while IFS= read -r -d '' file; do
      echo "  $(realpath "$file")"
    done < <(find "$SERVICES_DIR" -maxdepth 1 -type f -name "*.tfvars" -print0 2>/dev/null | sort -z) || true
  else
    echo "  (Verzeichnis '$SERVICES_DIR' nicht gefunden)"
  fi

  echo
  echo "Verfügbare Skripte:"
  if [ -d "$SCRIPTS_DIR" ]; then
    while IFS= read -r -d '' file; do
      echo "  $(realpath "$file")"
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" -print0 2>/dev/null | sort -z) || true
  else
    echo "  (Verzeichnis '$SCRIPTS_DIR' nicht gefunden)"
  fi
}

validate_service() {
  local service_name="$1"
  local tfvars_file="$SERVICES_DIR/${service_name}.tfvars"

  if [ -z "$service_name" ]; then
    echo "Error: Service-Name erforderlich (z. B. 'demo')." >&2
    exit 1
  fi

  if [ ! -f "$tfvars_file" ]; then
    echo "Error: Service-Datei '$tfvars_file' nicht gefunden." >&2
    exit 1
  fi

  echo "$tfvars_file"
}

run_terraform_with_service() {
  local action="$1"
  local service_name="$2"
  shift 2
  local tfvars_file
  tfvars_file="$(validate_service "$service_name")"

  ensure_init

  local cmd=("$TERRAFORM_BIN" "$action" "-var-file=$tfvars_file")

  case "$action" in
    apply|destroy)
      cmd+=("-auto-approve")
      ;;
  esac

  if [ -n "${HCLOUD_TOKEN:-}" ] && [ -z "${TF_VAR_hcloud_token:-}" ]; then
    export TF_VAR_hcloud_token="$HCLOUD_TOKEN"
  fi

  if [ -n "${PROXMOX_TOKEN:-}" ] && [ -z "${TF_VAR_proxmox_token:-}" ]; then
    export TF_VAR_proxmox_token="$PROXMOX_TOKEN"
  fi

  if [ $# -gt 0 ]; then
    cmd+=("$@")
  fi

  echo "Executing: ${cmd[*]}"
  "${cmd[@]}"
}

main() {
  if [ $# -lt 1 ]; then
    print_usage
    exit 1
  fi

  local subcommand="$1"
  shift || true

  case "$subcommand" in
    list)
      list_services
      ;;
    up)
      require_terraform
      if [ $# -lt 1 ]; then
        echo "Error: Service-Name erforderlich." >&2
        exit 1
      fi
      run_terraform_with_service apply "$@"
      ;;
    destroy)
      require_terraform
      if [ $# -lt 1 ]; then
        echo "Error: Service-Name erforderlich." >&2
        exit 1
      fi
      run_terraform_with_service destroy "$@"
      ;;
    plan)
      require_terraform
      if [ $# -lt 1 ]; then
        echo "Error: Service-Name erforderlich." >&2
        exit 1
      fi
      run_terraform_with_service plan "$@"
      ;;
    help|--help|-h)
      print_usage
      ;;
    *)
      echo "Error: Unbekanntes Subcommand '$subcommand'." >&2
      print_usage
      exit 1
      ;;
  esac
}

main "$@"
