#!/usr/bin/env bash
#
# Dieses Skript lädt ein Ubuntu-Cloud-Image herunter, installiert libguestfs-tools,
# modifiziert das Image mit Cloud-Init-Unterstützung und konvertiert es in ein
# Proxmox-Template.
#
# Basierend auf:
# https://www.thomas-krenn.com/de/wiki/Cloud_Init_Templates_in_Proxmox_VE_-_Quickstart
#
# Hinweis: Bitte ggf. an der Umgebung anpassen (VM-ID, Storage-Namen usw.).

set -e  # Skript bei Fehler abbrechen

# Ubuntu 22.04 Cloud-Image
# https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
# Ubuntu 24.04 Cloud-Image
# https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
# Debian 12 (Bookworm) Cloud-Image
# https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

VM_ID="9000"
VM_NAME="ubuntu-focal-cloudinit"
VM_BRIDGE="vmbr1"
VM_NAMESERVER="10.0.10.2"
VM_NAMESERVER_SEARCHDOMAIN="z1.navine.tech"
VM_BALLOON="1024"
VM_USER="ansible"
VM_ROOT_PASSWORD="Relation#1!"
VM_IP="dhcp" #bspw. sonst 10.0.10.123/24
VM_IP_GW="" # mit der GW-IP 10.0.10.1
STORAGE_NAME="local"  # Name des Storage in Proxmox
IMG_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
IMG_FILE="focal-server-cloudimg-amd64.img"
KEY_NAME="id_rsa"
KEY_DIR="$HOME/cloudinit/.ssh"
AUTHORIZED_KEYS="$KEY_DIR/authorized_keys"
SOURCE_SNIPPETS_DIR="./snippets"
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
# VM checken
if qm status $VM_ID > /dev/null 2>&1; then
    echo "Lösche VM mit ID $VM_ID..."
    qm stop $VM_ID
    qm destroy $VM_ID
    echo "VM mit ID $VM_ID wurde gelöscht."
else
    echo "Keine VM mit ID $VM_ID gefunden. Löschen nicht durchgeführt."
fi
# Image checken
if [ -f "$IMG_FILE" ]; then
    echo "Lösche Datei: $IMG_FILE..."
    rm "$IMG_FILE"
    echo "Datei $IMG_FILE wurde gelöscht."
else
    echo "Datei $IMG_FILE existiert nicht. Löschen nicht durchgeführt."
fi
# SSH Key checken
if [ ! -d "$KEY_DIR" ]; then
    echo "Erstelle .ssh Verzeichnis..."
    mkdir -p "$KEY_DIR"
    chmod 700 "$KEY_DIR"
fi
if [ ! -f "$KEY_DIR/$KEY_NAME" ]; then
    echo "SSH-Key $KEY_NAME existiert nicht. Erzeuge neuen SSH-Key..."
    ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY_NAME" -N ""
else
    echo "Vorhandener SSH-Key $KEY_NAME wird verwendet."
fi
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    echo "Erstelle authorized_keys Datei..."
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
fi
echo "Füge Public Key zur authorized_keys Datei hinzu..."
PUB_KEY=$(cat "$KEY_DIR/$KEY_NAME.pub")
if ! grep -qF "$PUB_KEY" "$AUTHORIZED_KEYS"; then
    echo "$PUB_KEY" >> "$AUTHORIZED_KEYS"
    echo "Public Key hinzugefügt."
else
    echo "Public Key ist bereits in authorized_keys vorhanden."
fi

# -----------------------------
# 2) Abhängigkeiten installieren
# -----------------------------
echo "==> Installing libguestfs-tools (needs sudo privileges)..."
sudo apt-get update && sudo apt-get install -y libguestfs-tools

# -----------------------------
# 3) Cloud-Image herunterladen
# -----------------------------
if [ ! -f "${IMG_FILE}" ]; then
  echo "==> Downloading Ubuntu Cloud Image..."
  wget -4 -O "${IMG_FILE}" "${IMG_URL}"
else
  echo "==> Cloud Image ${IMG_FILE} bereits vorhanden, Überspringe Download."
fi

# -----------------------------
# 4) Image anpassen (z. B. QEMU Guest Agent)
# -----------------------------
echo "==> Customizing image with virt-customize..."
sudo virt-customize -a "${IMG_FILE}" --install qemu-guest-agent

echo "==> Customizing image with virt-customize..."
sudo virt-customize -a "${IMG_FILE}" --root-password password:${VM_ROOT_PASSWORD}

echo "==> Customizing image with virt-customize..."
sudo virt-customize -a "${IMG_FILE}" --run-command "echo -n > /etc/machine-id"

# -----------------------------
# 5) Neue VM in Proxmox anlegen
# -----------------------------
echo "==> Creating VM ${VM_NAME} [ID ${VM_ID}] in Proxmox..."
qm create "${VM_ID}" --name "${VM_NAME}" --memory 2048 --cores 2 --net0 virtio,bridge=${VM_BRIDGE}

# -----------------------------
# 6) Image als Disk importieren
# -----------------------------
echo "==> Importing disk to Proxmox storage..."
qm importdisk "${VM_ID}" "${IMG_FILE}" "${STORAGE_NAME}"

# -----------------------------
# 7) Cloud-Init-Drive konfigurieren
# -----------------------------
echo "==> Attaching imported disk as scsi0..."
qm set "${VM_ID}" --scsihw virtio-scsi-single --scsi0 "${STORAGE_NAME}:${VM_ID}/vm-${VM_ID}-disk-0.raw,cache=writeback,discard=on,ssd=1"

qm set "${VM_ID}" --scsi1 "${STORAGE_NAME}:60,cache=writeback,discard=on,ssd=1"

echo "==> Setting boot options..."
qm set "${VM_ID}" --boot c --bootdisk scsi0

echo "==> Adding Cloud-Init drive..."
qm set "${VM_ID}" --scsi2 "${STORAGE_NAME}:cloudinit"

# -----------------------------
# 8) QEMU Guest Agent aktivieren
# -----------------------------
echo "==> Enabling QEMU Guest Agent..."
qm set "${VM_ID}" --agent 1

# -----------------------------
# 9) Weitere Anpassungen
# -----------------------------
echo "==> Adjustments..."

qm resize "${VM_ID}" scsi0 +27748M 

qm set "${VM_ID}" --serial0 socket 

qm set "${VM_ID}" --vga serial0 

qm set "${VM_ID}" --cpu cputype=host 

qm set "${VM_ID}" --ostype l26 

qm set "${VM_ID}" --balloon ${VM_BALLOON}

qm set "${VM_ID}" --ciupgrade 1 

qm set "${VM_ID}" --ciuser "${VM_USER}"

if [[ "$VM_IP" == "dhcp" ]]; then
    qm set "${VM_ID}" --ipconfig0 ip=dhcp
else
    qm set "${VM_ID}" --ipconfig0 ip=$VM_IP,gw=$VM_IP_GW
fi

qm set "${VM_ID}" --nameserver "${VM_NAMESERVER}" 

qm set "${VM_ID}" --searchdomain "${VM_NAMESERVER_SEARCHDOMAIN}" 

qm set "${VM_ID}" --sshkeys "${AUTHORIZED_KEYS}" 

# -----------------------------
# 10) VM in ein Template konvertieren
# -----------------------------
echo "==> Converting VM ${VM_ID} into a template..."
qm template "${VM_ID}"

echo "==> Done!"
echo "Die Cloud-Init-Template-VM '${VM_NAME}' (ID ${VM_ID}) ist jetzt in Proxmox verfügbar."
echo "Viel Spaß beim Klonen und Cloud-Init-Testen!"
