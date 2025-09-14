#!/usr/bin/env bash
#

set -e 

SOURCE_SNIPPETS_DIR="/opt/TID/scripts/proxmox/snippets"
SNIPPETS_DIR="/var/lib/vz/snippets"

# Snippet
if [ ! -d "$SNIPPETS_DIR" ]; then
  echo "Ordner $SNIPPETS_DIR wird erstellt..."
  mkdir -p "$SNIPPETS_DIR"
else
  echo "Ordner $SNIPPETS_DIR existiert bereits."
fi
echo "Verschieben von Dateien und Ordnern aus $SOURCE_SNIPPETS_DIR nach $SNIPPETS_DIR..."
if [ -d "$SOURCE_SNIPPETS_DIR" ]; then
  cp -rf "$SOURCE_SNIPPETS_DIR"/* "$SNIPPETS_DIR"/
  echo "Alle Dateien und Ordner wurden erfolgreich verschoben (überschrieben, falls vorhanden)."
else
  echo "Quellordner $SOURCE_SNIPPETS_DIR existiert nicht. Bitte überprüfen."
  exit 1
fi
