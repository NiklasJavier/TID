terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.45"
    }
    # https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

####################################################
# Dyn. Proxmox Server-Loader aus services/*.tfvars
####################################################

module "proxmox_servers" {
  for_each = { for server in var.servers_proxmox : server.proxmox_service_name => server }

  source = "./modules/proxmox"
  providers = {
    proxmox = proxmox
  }

  proxmox_server_count      = each.value.proxmox_server_count
  proxmox_server_base_ip    = each.value.proxmox_server_base_ip
  proxmox_server_start_ip   = each.value.proxmox_server_start_ip
  proxmox_start_vmid        = each.value.proxmox_start_vmid
  proxmox_owner_prefix      = each.value.proxmox_owner_prefix
  proxmox_service_name      = each.value.proxmox_service_name
  proxmox_desc              = each.value.proxmox_desc
  proxmox_target_node       = each.value.proxmox_target_node
  proxmox_cicustom_snippets = each.value.proxmox_cicustom_snippets
  proxmox_clone_template    = each.value.proxmox_clone_template
  proxmox_sshkeys           = each.value.proxmox_sshkeys
  proxmox_cores             = each.value.proxmox_cores
  proxmox_memory            = each.value.proxmox_memory
}

####################################################
# Dyn. Hetzner Server-Loader aus services/*.tfvars
####################################################
module "hetzner_servers" {
  for_each = { for server in var.servers_hetzner : server.hcloud_service_name => server }

  source = "./modules/hetzner"
  providers = {
    hcloud = hcloud
  }

  hcloud_server_count          = each.value.hcloud_server_count
  hcloud_server_base_ip        = each.value.hcloud_server_base_ip
  hcloud_server_start_ip       = each.value.hcloud_server_start_ip
  hcloud_owner_prefix          = each.value.hcloud_owner_prefix
  hcloud_service_name          = each.value.hcloud_service_name
  hcloud_server_type           = each.value.hcloud_server_type
  hcloud_image                 = each.value.hcloud_image
  hcloud_datacenter            = each.value.hcloud_datacenter
  hcloud_server_user_data_file = each.value.hcloud_server_user_data_file
  hcloud_server_labels         = each.value.hcloud_server_labels
  hcloud_firewall_rules        = each.value.hcloud_firewall_rules
}





