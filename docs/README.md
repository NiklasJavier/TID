# Service-Übersicht

Diese Dokumentation bietet eine schnelle Übersicht über alle aktuell gepflegten Services und die dazugehörigen Terraform-Variablendateien. Jeder Abschnitt enthält die wichtigsten Betriebsparameter sowie Hinweise zum Ausführen der Standard-Terraform-Befehle.

## Allgemeine Nutzung

Führe die folgenden Befehle im Repository-Wurzelverzeichnis aus und ersetze `<service-datei>` durch den gewünschten `.tfvars`-Pfad.

```bash
terraform init
terraform plan -var-file="<service-datei>"
terraform apply -var-file="<service-datei>"
terraform destroy -var-file="<service-datei>"
```

## Services

### `services/demo.tfvars`

Mehrere Proxmox-Instanzen für die Demonstrationsumgebung der Container-Management-Plattform.

| Service | Beschreibung | Zielnode | Start-IP | Start-VMID | CPU | RAM (MiB) |
| --- | --- | --- | --- | --- | --- | --- |
| apex | Container Management für Docker-Container | HFAL-PRX01 | 10.15.1.111 | 111 | 2 | 2048 |
| citadel | – | HFAL-PRX01 | 10.15.1.112 | 112 | 2 | 2048 |
| beacon | – | HFAL-PRX01 | 10.15.1.113 | 113 | 2 | 2048 |
| vox | – | HFAL-PRX01 | 10.15.1.114 | 114 | 2 | 2048 |

### `services/kt-prototyp/chat.tfvars`

Ein Proxmox-Server für die Chat-Plattform des KT-Prototyps.

| Service | Beschreibung | Zielnode | Start-IP | Start-VMID | CPU | RAM (MiB) |
| --- | --- | --- | --- | --- | --- | --- |
| chat | für die Chat-Plattform | HFAL-PRX01 | 10.15.1.191 | 1191 | 4 | 4096 |

### `services/kt-prototyp/kdata.tfvars`

Ein Proxmox-Server für die Datenplattform des KT-Prototyps.

| Service | Beschreibung | Zielnode | Start-IP | Start-VMID | CPU | RAM (MiB) |
| --- | --- | --- | --- | --- | --- | --- |
| kdata | für die KData-Plattform | HFAL-PRX01 | 10.15.1.192 | 1192 | 4 | 4096 |

