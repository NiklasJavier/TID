#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
DEFAULT_VERSION="1.6.6"
REQUESTED_VERSION="${1:-${TERRAFORM_VERSION:-$DEFAULT_VERSION}}"
INSTALL_BASE="${TERRAFORM_CACHE_DIR:-$REPO_ROOT/.terraform-bin}"

detect_platform() {
  local os arch

  case "$(uname -s)" in
    Linux)
      os="linux"
      ;;
    Darwin)
      os="darwin"
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)" >&2
      exit 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64)
      arch="amd64"
      ;;
    arm64|aarch64)
      arch="arm64"
      ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  echo "$os" "$arch"
}

ensure_dependencies() {
  command -v curl >/dev/null 2>&1 || {
    echo "curl is required to download Terraform." >&2
    exit 1
  }

  command -v unzip >/dev/null 2>&1 || {
    echo "unzip is required to extract Terraform archives." >&2
    exit 1
  }
}

download_terraform() {
  local version="$1" os="$2" arch="$3" target_dir="$4"
  local url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip"

  mkdir -p "$target_dir"

  local zip_file
  zip_file="$(mktemp "${TMPDIR:-/tmp}/terraform-${version}-${os}-${arch}.XXXXXX.zip")"

  echo "Downloading Terraform ${version} (${os}/${arch}) ..." >&2
  curl -fsSL "$url" -o "$zip_file"

  unzip -q -o "$zip_file" -d "$target_dir"
  rm -f "$zip_file"
}

main() {
  ensure_dependencies
  read -r os arch < <(detect_platform)

  local install_dir="$INSTALL_BASE/${REQUESTED_VERSION}/${os}-${arch}"
  local binary_path="$install_dir/terraform"

  if [ ! -x "$binary_path" ]; then
    download_terraform "$REQUESTED_VERSION" "$os" "$arch" "$install_dir"
    chmod +x "$binary_path"
  fi

  printf '%s\n' "$binary_path"
}

main "$@"
