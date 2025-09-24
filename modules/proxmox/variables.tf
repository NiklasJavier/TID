variable "proxmox_server_count" {
  type    = number
  default = 1
}

variable "proxmox_server_base_ip" {
  type    = string
  default = "10.15.1."
}

variable "proxmox_server_start_ip" {
  type    = number
  default = 100
}

variable "proxmox_service_name" {
  description = "Name der VM"
  type        = string
  default     = "srv-demo-1"
}

variable "proxmox_desc" {
  description = "Beschreibung der VM"
  type        = string
  default     = "Ubuntu-Server"
}

variable "proxmox_target_node" {
  description = "Proxmox Ziel-Node"
  type        = string
  default     = "HFAL-PRX01"
}

variable "proxmox_sshkeys" {
  description = "SSH-Keys für die VM"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj8ipwPHVSI/yvERzILBD52zL1jj6Ja3ptWlVhR0WK6ElBekwKL314Sps79xAitJb"
}

variable "proxmox_clone_template" {
  description = "Template, das geklont werden soll"
  type        = string
  default     = "ubuntu-focal-cloudinit"
}

variable "proxmox_qemu_os" {
  description = "Betriebssystemtyp für QEMU"
  type        = string
  default     = "l26"
}

variable "proxmox_cores" {
  description = "Anzahl der CPU-Kerne"
  type        = number
  default     = 2
}

variable "proxmox_sockets" {
  description = "Anzahl der CPU-Sockets"
  type        = number
  default     = 1
}

variable "proxmox_cpu" {
  description = "CPU-Typ für die VM"
  type        = string
  default     = "host"
}

variable "proxmox_memory" {
  description = "Arbeitsspeichergröße in MB"
  type        = number
  default     = 8096
}

variable "proxmox_scsihw" {
  description = "Virtuelle SCSI-Hardware"
  type        = string
  default     = "virtio-scsi-single"
}

variable "proxmox_disk_storage" {
  description = "Speicher für die Festplatte"
  type        = string
  default     = "local"
}

variable "proxmox_disk_size" {
  description = "Größe der Festplatte"
  type        = string
  default     = "83212M"
}

variable "proxmox_network_bridge" {
  description = "Name der Netzwerk-Bridge"
  type        = string
  default     = "vmbr1"
}

variable "proxmox_network_model" {
  description = "Netzwerkadaptermodell"
  type        = string
  default     = "virtio"
}

variable "proxmox_cloud_init_os_type" {
  description = "Betriebssystemtyp für Cloud-Init"
  type        = string
  default     = "cloud-init"
}

variable "proxmox_cloud_init_ipconfig0" {
  description = "Netzwerk-IP-Konfiguration für Cloud-Init"
  type        = string
  default     = "ip=dhcp"
}

variable "proxmox_cloud_init_nameserver" {
  description = "Nameserver für Cloud-Init"
  type        = string
  default     = "10.0.10.2"
}

variable "proxmox_cloud_init_ciuser" {
  description = "Benutzername für Cloud-Init"
  type        = string
  default     = "root"
}

variable "proxmox_cloud_init_ciuser_password" {
  description = "Passwort für Cloud-Init root-Benutzer"
  type        = string
  default     = "root"
}

variable "proxmox_cicustom_snippets" {
  description = "List of custom CI snippets for Proxmox."
  type        = list(string)
  default = [
    "vendor=local:snippets/qemu-guest-agent.yml"
  ]
}

variable "proxmox_start_vmid" {
  description = "VM-ID"
  type        = string
}

# Ansible-spezifische Variablen
variable "ansible_repo_url" {
  description = "URL des Git-Repositories mit Ansible-Playbooks"
  type        = string
  default     = "https://github.com/your-repo.git"
}

variable "ansible_playbook_path" {
  description = "Pfad zum Ansible-Playbook"
  type        = string
  default     = "playbooks/main.yml"
}

variable "ansible_extra_vars" {
  description = "Zusätzliche Variablen für das Ansible-Playbook"
  type        = string
  default     = "key=value"
}

variable "proxmox_owner_prefix" {
  type    = string
  default = "NV"
}

