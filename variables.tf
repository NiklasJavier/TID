variable "hetzner_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "proxmox_api_url" {
  type        = string
  description = "API Url of the Proxmox instance"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "API Token ID for Proxmox"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "API Token Secret for Proxmox"
  sensitive   = true
}

variable "servers_proxmox" {
  description = "Liste der Proxmox-Serverkonfigurationen"
  type = list(object({
    proxmox_server_count      = number
    proxmox_server_base_ip    = string
    proxmox_server_start_ip   = number
    proxmox_start_vmid        = number
    proxmox_owner_prefix      = string
    proxmox_service_name      = string
    proxmox_desc              = string
    proxmox_target_node       = string
    proxmox_cicustom_snippets = list(string)
    proxmox_clone_template    = string
    proxmox_sshkeys           = string
    proxmox_cores             = number
    proxmox_memory            = number
  }))
}

variable "servers_hetzner" {
  description = "Liste der Hetzner-Serverkonfigurationen"
  type = list(object({
    hcloud_server_count        = number
    hcloud_server_base_ip      = string
    hcloud_server_start_ip     = number
    hcloud_owner_prefix        = string
    hcloud_service_name        = string
    hcloud_server_type         = string
    hcloud_image               = string
    hcloud_datacenter          = string
    hcloud_server_user_data_file = string
    hcloud_server_labels       = map(string)
    hcloud_firewall_rules      = list(object({
      direction  = string
      protocol   = string
      port       = string
      source_ips = list(string)
    }))
  }))
}
