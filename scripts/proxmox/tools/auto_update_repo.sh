#!/bin/bash

REPO_DIR="/opt/TID"
REPO_URL="https://github.com/NiklasJavier/TID.git"
SNIPPETS_SUBPATH="scripts/proxmox/snippets"

cd "$REPO_DIR" || exit 1

git fetch "$REPO_URL" main

LOCAL=$(git rev-parse HEAD)       
REMOTE=$(git rev-parse FETCH_HEAD)

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "Änderungen erkannt. Pull wird ausgeführt..."
  git pull "$REPO_URL" main

  CHANGED_FILES=$(git diff --name-only "$LOCAL" HEAD)

  if echo "$CHANGED_FILES" | grep -qE "^${SNIPPETS_SUBPATH}/"; then
    echo "Snippets-Dateien haben sich geändert. Führe weiteres Skript aus..."
    cd /opt/TID/scripts
    find . -type f -name "*.sh" -exec chmod +x {} \; &&
    /opt/TID/scripts/proxmox/transfer-snippets.sh
  else
    echo "Keine Änderungen im Ordner '$SNIPPETS_SUBPATH'."
  fi

else
  echo "Keine Änderungen."
fi
