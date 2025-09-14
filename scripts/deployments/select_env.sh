#!/bin/bash

ROOT_DIR=$(pwd)
ENV_DIR="$ROOT_DIR/env"
TARGET_FILE="$ROOT_DIR/terraform.tfvars"

ENVIRONMENTS=($(find "$ENV_DIR" -maxdepth 1 -type f -name "*.tfvars" -exec basename {} \; | sed 's/\.tfvars$//'))

if [[ ${#ENVIRONMENTS[@]} -eq 0 ]]; then
    echo "Keine Umgebungsdateien (.tfvars) im Ordner $ENV_DIR gefunden. Abbruch."
    exit 1
fi

echo "Verfügbare Umgebungen:"
for env in "${ENVIRONMENTS[@]}"; do
    echo "- $env"
done

read -p "Bitte die gewünschte Umgebung auswählen: " selected_env

if [[ ! " ${ENVIRONMENTS[@]} " =~ " ${selected_env} " ]]; then
    echo "Ungültige Umgebung ausgewählt! Abbruch."
    exit 1
fi

SOURCE_FILE="$ENV_DIR/${selected_env}.tfvars"

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Die Datei $SOURCE_FILE existiert nicht. Abbruch."
    exit 1
fi

if [[ -f "$TARGET_FILE" ]]; then
    read -p "Die Datei $TARGET_FILE existiert bereits. Soll sie überschrieben werden? (y/n): " overwrite
    if [[ "$overwrite" != "y" ]]; then
        echo "Abbruch. Die Datei wurde nicht überschrieben."
        exit 0
    fi
fi

cp "$SOURCE_FILE" "$TARGET_FILE"
echo "Die Datei $SOURCE_FILE wurde erfolgreich nach $TARGET_FILE kopiert."

echo
echo "### Hinweis"
echo "Passe die Datei ./terraform.tfvars entsprechend an:"
echo
echo "### Proxmox-Umgebung:"
echo "Bitte lesen Sie das Kapitel 'Terraform Proxmox Token' aus der README.md, um die folgenden Variablen korrekt festzulegen:"
echo "  * proxmox_api_url"
echo "  * proxmox_api_token_id"
echo "  * proxmox_api_token_secret"
echo
echo "### Hetzner-Umgebung:"
echo "Falls eine Hetzner-Umgebung verwendet wird, erstellen Sie ein Token in den Einstellungen der Hetzner Cloud Console:"
echo "  * hetzner_token"
