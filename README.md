### TID (Terraform Infrastructure Deployment)
## Umgebungssteuerung (Benötigt [Setup](#setup)) Bspw.
Eigene Service können unter dem Verzeichnis `services/*` angelegt werden:
Beispiel `services/demo.tfvars`:
```bash
terraform init &&
terraform plan -var-file="./services/demo.tfvars" &&
terraform apply -var-file="./services/demo.tfvars" &&
terraform destroy -var-file="./services/demo.tfvars"
```
---
## Setup
---
### Terraform Steuerungsknoten
```bash
git clone https://github.com/NiklasJavier/TID.git ./TID && 
cd TID && 
bash ./scripts/deployments/select_env.sh
```
---
### Terraform Proxmox Token

Role: Terraform
User: terraform@pam
FullTokenID: terraform@pam!terraformAccessToken 

```bash
pveum role add Terraform --privs "VM.Allocate,VM.PowerMgmt,VM.Config.CPU,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.Monitor,VM.Backup,VM.Audit" &&
pveum user add terraform@pam --comment "Terraform User" &&
pveum aclmod / -user terraform@pam -role Terraform &&
pveum user token add terraform@pam terraformAccessToken --privsep 0 &&
pveum user token list terraform@pam
```

Um die Details des Tokens (z. B. Token-ID) zu überprüfen, kannst du den folgenden Befehl verwenden:
```bash
pveum user token list terraform@pam
```

entfernen
```bash
pveum user token delete terraform@pam terraformAccessToken &&
pveum user delete terraform@pam &&
pveum role delete Terraform 
```

Hierbei wird ein Token mit dem Namen ⁠terraform-token für den Benutzer ⁠terraform erstellt. Das Terminal gibt dir eine Token-ID aus, die du für API-Anfragen verwenden kannst.

---
## Für Proxmox Host-Setup
```bash
rm -rf "/opt/TID" &&
git clone https://github.com/NiklasJavier/TID.git /opt/TID &&
cd /opt/TID/scripts/proxmox &&
chmod +x setup-cloudinit.sh &&
find . -type f -name "*.sh" -exec chmod +x {} \; &&
cat /root/cloudinit/.ssh/id_rsa
cd /opt
echo "alias tid='bash /opt/TID/scripts/proxmox/tools/auto_update_repo.sh && cd /opt/TID/scripts/'" >> ~/.bashrc && 
source ~/.bashrc
```
---
## Für Proxmox Snippets Upload
```bash
rm -rf "/opt/TID" &&
git clone https://github.com/NiklasJavier/TID.git /opt/TID &&
cd /opt/TID/scripts/proxmox &&
find . -type f -name "*.sh" -exec chmod +x {} \; &&
./transfer-snippets.sh &&
cd /opt
```
---
## Für Proxmox Tool AutoUpdate Repo 1min
```bash
rm -rf "/opt/TID" &&
git clone https://github.com/NiklasJavier/TID.git /opt/TID &&
cd /opt/TID/scripts/proxmox &&
find . -type f -name "*.sh" -exec chmod +x {} \; &&
cd /opt &&
[ -z "$(crontab -l 2>/dev/null | grep '/opt/TID/scripts/proxmox/tools/auto_update_repo.sh')" ] && \
  (crontab -l 2>/dev/null; echo "*/1 * * * * /bin/bash /opt/TID/scripts/proxmox/tools/auto_update_repo.sh") | crontab - 
```

## Für Proxmox Tool AutoUpdate Repo (manuell)
```bash
bash /opt/TID/scripts/proxmox/tools/auto_update_repo.sh
```

## Kürzel (tid): Für Proxmox Tool AutoUpdate Repo + Directory
```bash
echo "alias tid='bash /opt/TID/scripts/proxmox/tools/auto_update_repo.sh && cd /opt/TID/scripts/'" >> ~/.bashrc && 
source ~/.bashrc
```
---

# Dynamische Erstellung von Proxmox- und Hetzner-Servern

Dieses Terraform-Repository ermöglicht die **dynamische Erstellung von Proxmox- und Hetzner-Servern** durch die Definition einer zentralen Server-Konfigurationsdatei (`services/*.tfvars`). Die Konfiguration ist flexibel und skalierbar, sodass mehrere Server mit individuellen Einstellungen erstellt werden können.

---

## Inhaltsverzeichnis
1. [Features](#features)
2. [Voraussetzungen](#voraussetzungen)
3. [Schnellstart](#schnellstart)
4. [Konfiguration](#konfiguration)
   - [Proxmox-Server](#proxmox-server)
   - [Hetzner-Server](#hetzner-server)
5. [Module](#module)
6. [Beispiele](#beispiele)

---

## Features

- **Dynamische Servererstellung** für Proxmox und Hetzner.
- Unterstützung für:
  - Mehrere Server mit individuellen Konfigurationen.
  - Cloud-Init-Snippets und SSH-Schlüssel.
  - Benutzerdefinierte Firewall-Regeln (für Hetzner).
- Zentrale Verwaltung der Serverdefinitionen in `services/*.tfvars`.

---

## Voraussetzungen

- **Terraform** (Version >= 1.0.0)
- Zugriff auf:
  - **Proxmox API** mit Token.
  - **Hetzner Cloud API** mit Token.
- SSH-Schlüssel für den Zugriff auf die Server (optional).
- Cloud-Init-Templates oder benutzerdefinierte Snippets (falls benötigt).

---

## Schnellstart

1. **Repository klonen**
   ```bash
   git clone https://github.com/NiklasJavier/TID.git /opt/TID && 
   cd /opt/TID &&
   bash ./scripts/deployments/select_env.sh
   ```

2. **Terraform initialisieren**
   ```bash
   terraform init
   ```

3. **Konfiguration anpassen**
   - Bearbeite die Datei `terraform.tfvars` und `services/*.tfvars` definiere deine Serverkonfigurationen (siehe [Konfiguration](#konfiguration)).

4. **Plan prüfen bspw.**
   ```bash
   terraform plan -var-file="./services/demo.tfvars"
   ```

5. **Server erstellen bspw.**
   ```bash
   terraform apply -var-file="./services/demo.tfvars
   ```

---

## Konfiguration

Die Serverdefinition erfolgt über zwei Listen: 
- `servers_proxmox` für Proxmox-Server.
- `servers_hetzner` für Hetzner-Server.

Beide Listen können beliebig viele Serverkonfigurationen enthalten.

### Proxmox-Server

Ein Proxmox-Server wird durch die folgenden Parameter definiert:

### Tabelle: Proxmox-Service-Beispiele

| **Service Name**  | **Beschreibung**                | **CPU (Cores)** | **RAM (MB)** | **Disk (GB)** | **Start-IP**     | **VMID**  | **Target Node** | **VM Template**             | **Tags**              | **Cloud-Init Snippets**                   |
|--------------------|--------------------------------|-----------------|--------------|---------------|------------------|-----------|-----------------|-----------------------------|-----------------------|------------------------------------------|
| `eai`             | EAI-Plattform für Integration  | 2               | 2048         | 20            | 10.15.1.100      | 100       | `HFAL-PRX01`   | `ubuntu-focal-cloudinit`    | `["eai", "production"]` | `["qemu-guest-agent.yml", "default.yml"]` |
| `web-app`         | Webanwendung Frontend          | 4               | 4096         | 30            | 10.15.1.110      | 110       | `HFAL-PRX02`   | `ubuntu-focal-cloudinit`    | `["web", "frontend"]` | `["default.yml"]`                        |
| `db`              | PostgreSQL Datenbankserver     | 6               | 8192         | 50            | 10.15.1.120      | 120       | `HFAL-PRX03`   | `debian-cloudinit`          | `["db", "production"]` | `["default.yml"]`                        |
| `test`            | Testumgebung für Staging       | 2               | 2048         | 20            | 10.15.1.130      | 130       | `HFAL-PRX04`   | `ubuntu-focal-cloudinit`    | `["test", "staging"]` | `["default.yml"]`                        |
| `cache`           | Redis Cache Node               | 2               | 4096         | 20            | 10.15.1.140      | 140       | `HFAL-PRX01`   | `debian-cloudinit`          | `["cache", "backend"]` | `["default.yml"]`                        |

---

### Erklärung der Parameter

| **Parameter**           | **Beschreibung**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| **Service Name**        | Der Name des Dienstes, der in der Proxmox-Konfiguration verwendet wird.                             |
| **Beschreibung**        | Eine kurze Beschreibung des Dienstes und seiner Verwendung.                                        |
| **CPU (Cores)**         | Anzahl der CPU-Kerne, die der VM zugewiesen werden.                                                |
| **RAM (MB)**            | Arbeitsspeicher (RAM) in Megabyte.                                                                 |
| **Disk (GB)**           | Festplattenspeicher in Gigabyte.                                                                   |
| **Start-IP**            | Start-IP-Adresse, die der ersten Instanz zugewiesen wird.                                          |
| **VMID**                | Virtuelle Maschinen-ID für die VM.                                                                 |
| **Target Node**         | Der Ziel-Node innerhalb des Proxmox-Clusters.                                                      |
| **VM Template**         | Die Vorlage, die für die Erstellung der VM verwendet wird (z. B. Cloud-Init-basiert).              |
| **Tags**                | Tags zur Kennzeichnung und einfachen Verwaltung der VM (z. B. für Monitoring oder Organisation).    |
| **Cloud-Init Snippets** | Eine Liste von YAML-Dateien, die während der Erstellung der VM angewendet werden.                  |

```hcl
servers_proxmox = [
  {
    proxmox_server_count      = 2                     # Anzahl der Server
    proxmox_server_base_ip    = "10.15.1."            # Basis-IP
    proxmox_server_start_ip   = 100                   # Start-IP
    proxmox_start_vmid        = 100                   # Start-VMID
    proxmox_owner_prefix      = "NV"                  # Präfix für Servernamen
    proxmox_service_name      = "eai"                 # Name des Dienstes
    proxmox_desc              = "für die EAI-Plattform" # Beschreibung
    proxmox_target_node       = "HFAL-PRX01"          # Ziel-Node
    proxmox_cicustom_snippets = [                     # Cloud-Init-Snippets
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit" # VM-Vorlage
    proxmox_sshkeys           = "ssh-ed25519 AAAAC..."   # SSH-Schlüssel
    proxmox_cores             = 2                      # Anzahl der CPU-Kerne
    proxmox_memory            = 2048                   # RAM (MB)
  }
]
```

### Hetzner-Server

Ein Hetzner-Server wird durch die folgenden Parameter definiert:
### Tabelle: Hetzner-Service-Beispiele

| **Service Name**  | **Beschreibung**                | **Server Typ** | **Image**          | **Datacenter** | **Anzahl Server** | **Start-IP**     | **Labels**              | **Firewall Regeln**    | **User Data File**                 |
|--------------------|--------------------------------|----------------|--------------------|----------------|--------------------|------------------|-------------------------|-------------------------|------------------------------------|
| `eai`             | EAI-Plattform für Integration  | `cx31`         | `ubuntu-22.04`     | `fsn1-dc14`    | 2                  | 172.16.245.100   | `{"service": "eai"}`    | SSH, ICMP, HTTPS        | `scripts/hetzner/eai-cloud-init.yaml` |
| `web-app`         | Frontend-Webanwendung          | `cx21`         | `ubuntu-22.04`     | `nbg1-dc3`     | 1                  | 172.16.245.110   | `{"service": "web"}`    | SSH, HTTP, HTTPS        | `scripts/hetzner/web-app-init.yaml` |
| `db`              | PostgreSQL Datenbankserver     | `cx41`         | `debian-11`        | `hel1-dc2`     | 1                  | 172.16.245.120   | `{"service": "db"}`     | SSH, Custom Ports       | `scripts/hetzner/db-cloud-init.yaml` |
| `test`            | Testumgebung für Staging       | `cx11`         | `ubuntu-20.04`     | `fsn1-dc14`    | 1                  | 172.16.245.130   | `{"service": "test"}`   | SSH, ICMP               | `scripts/hetzner/test-init.yaml`    |
| `cache`           | Redis Cache Node               | `cx21`         | `ubuntu-22.04`     | `fsn1-dc14`    | 1                  | 172.16.245.140   | `{"service": "cache"}`  | SSH, Redis Ports        | `scripts/hetzner/cache-init.yaml`   |

---

### Erklärung der Parameter

| **Parameter**           | **Beschreibung**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| **Service Name**        | Der Name des Dienstes, der in der Hetzner-Konfiguration verwendet wird.                             |
| **Beschreibung**        | Eine kurze Beschreibung des Dienstes und seiner Verwendung.                                        |
| **Server Typ**          | Hetzner-Server-Typ (z. B. `cx21`, `cx31`, `cx41`), je nach Anforderungen an CPU, RAM und Storage.    |
| **Image**               | Betriebssystem-Image, das für die Instanz verwendet wird (z. B. `ubuntu-22.04`, `debian-11`).       |
| **Datacenter**          | Standort des Rechenzentrums (z. B. `fsn1-dc14`, `nbg1-dc3`).                                        |
| **Anzahl Server**       | Anzahl der Server-Instanzen, die für den Service erstellt werden.                                   |
| **Start-IP**            | Start-IP-Adresse, die der ersten Instanz zugewiesen wird.                                           |
| **Labels**              | Key-Value-Labels für Management und Identifikation der Server (z. B. Service, Umgebung).           |
| **Firewall Regeln**     | Netzwerkregeln, die Zugriffe auf die Server erlauben oder blockieren (z. B. SSH, ICMP, HTTPS).      |
| **User Data File**      | Cloud-Init-Skript für die automatisierte Serverinitialisierung (z. B. Paketinstallation, User-Setup).|

```hcl
servers_hetzner = [
  {
    hcloud_server_count        = 2                            # Zwei Server für Hochverfügbarkeit
    hcloud_server_base_ip      = "172.16.245."                # Basis-IP-Adresse des Netzwerks
    hcloud_server_start_ip     = 100                          # Start der IP-Zuweisung
    hcloud_owner_prefix        = "EAI"                        # Präfix zur Identifikation des Dienstes
    hcloud_service_name        = "enterprise-app"             # Name des Dienstes
    hcloud_server_type         = "cx31"                       # Leistungsstärkerer Server-Typ
    hcloud_image               = "ubuntu-22.04"               # Neuere Ubuntu-Version
    hcloud_datacenter          = "fsn1-dc14"                  # Rechenzentrum
    hcloud_server_user_data_file = "scripts/hetzner/eai-cloud-init.yaml" # Spezifisches Cloud-Init-Skript
    hcloud_server_labels       = {                            # Labels für Management
      "service" = "eai"
      "env"     = "production"
      "team"    = "integration"
    }
    hcloud_firewall_rules = [                                 # Restriktivere Firewall-Regeln
      {
        direction  = "in"
        protocol   = "icmp"
        port       = ""
        source_ips = ["192.168.0.0/16", "::/0"]               # Nur interne Netzwerke können pingen
      },
      {
        direction  = "in"
        protocol   = "tcp"
        port       = "22"
        source_ips = ["192.168.1.0/24"]                       # SSH-Zugriff nur von einem Subnetz
      },
      {
        direction  = "in"
        protocol   = "tcp"
        port       = "443"
        source_ips = ["0.0.0.0/0", "::/0"]                    # HTTPS-Zugriff von überall
      }
    ]
  }
]
```

---

## Module

Dieses Repository enthält zwei Module zur Verwaltung der Server:

### 1. Proxmox-Modul (`./modules/proxmox`)
- Dynamische Erstellung von Proxmox-VMs basierend auf der Konfiguration in `servers_proxmox`.
- Unterstützt:
  - Mehrere Server pro Dienst.
  - Individuelle Cloud-Init-Snippets.
  - Benutzerdefinierte Serverressourcen (z. B. CPU, RAM).

### 2. Hetzner-Modul (`./modules/hetzner`)
- Dynamische Erstellung von Hetzner-Cloud-Servern basierend auf der Konfiguration in `servers_hetzner`.
- Unterstützt:
  - Firewall-Regeln pro Server.
  - Labels für Dienste.
  - Cloud-Init-Konfigurationen.

---

## Beispiele

### Beispiel 1: Proxmox-Server mit zwei Instanzen

```hcl
servers_proxmox = [
  {
    proxmox_server_count      = 2
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 100
    proxmox_start_vmid        = 100
    proxmox_owner_prefix      = "NV"
    proxmox_service_name      = "eai"
    proxmox_desc              = "für die EAI-Plattform"
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "ssh-ed25519 AAAAC..."
    proxmox_cores             = 2
    proxmox_memory            = 2048
  }
]
```

### Beispiel 2: Hetzner-Server mit zwei Instanzen

```hcl
servers_hetzner = [
  {
    hcloud_server_count        = 2
    hcloud_server_base_ip      = "172.16.245."
    hcloud_server_start_ip     = 100
    hcloud_owner_prefix        = "NV"
    hcloud_service_name        = "eai"
    hcloud_server_type         = "cax11"
    hcloud_image               = "ubuntu-20.04"
    hcloud_datacenter          = "fsn1-dc14"
    hcloud_server_user_data_file = "scripts/hetzner/snippets/init-zerotier.yaml"
    hcloud_server_labels       = {
      "eai" = "true"
    }
    hcloud_firewall_rules = [
      {
        direction  = "in"
        protocol   = "icmp"
        port       = ""
        source_ips = ["0.0.0.0/0", "::/0"]
      },
      {
        direction  = "in"
        protocol   = "tcp"
        port       = "22"
        source_ips = ["0.0.0.0/0", "::/0"]
      }
    ]
  }
]
```

---

## Erweiterungsideen

- **Neuer Provider:** Module können leicht für andere Provider erweitert werden (z. B. AWS, Azure).
- **Zusätzliche Ressourcen:** Du kannst Module anpassen, um Netzwerke, Volumes oder andere Infrastrukturressourcen zu erstellen.
