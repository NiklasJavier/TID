# README

Nach Abschluss findest du in Proxmox eine neue Template-VM mit der ID **9000** (oder deiner konfigurierten ID).

Da in Terraform die Verwendung von Cloud-Images sinnvoll ist, hier ein kurzer Einblick, wie man ein solches Cloud-Image erstellt und modifiziert.  

Auf dem Proxmox-Hypervisor wird ein **Ubuntu-Image** heruntergeladen und das Paket **libguestfs-tools** installiert, um im Cloud-Image Änderungen vornehmen zu können. [2]

Weitere Details zur Erstellung von Cloud-Init-Templates findest du im Artikel:  
**[Cloud Init Templates in Proxmox VE – Quickstart](https://www.thomas-krenn.com/de/wiki/Cloud_Init_Templates_in_Proxmox_VE_-_Quickstart)**
