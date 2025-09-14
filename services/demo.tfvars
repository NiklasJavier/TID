####################################################
# terraform init
# terraform plan -var-file="./services/demo.tfvars"
# terraform apply -var-file="./services/demo.tfvars"
# terraform destroy -var-file="./services/demo.tfvars"
####################################################

servers_proxmox = [
  {
    proxmox_server_count      = 1
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 111
    proxmox_start_vmid        = 111
    proxmox_owner_prefix      = "nvm"
    proxmox_service_name      = "apex"
    proxmox_desc              = "Container Management für Docker-Container"
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "(Dein-SSH-Public-Key)"
    proxmox_cores             = 2
    proxmox_memory            = 2048
  },
  {
    proxmox_server_count      = 1
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 112
    proxmox_start_vmid        = 112
    proxmox_owner_prefix      = "nvm"
    proxmox_service_name      = "citadel"
    proxmox_desc              = ""
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "(Dein-SSH-Public-Key)"
    proxmox_cores             = 2
    proxmox_memory            = 2048
  },
  {
    proxmox_server_count      = 1
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 113
    proxmox_start_vmid        = 113
    proxmox_owner_prefix      = "nvm"
    proxmox_service_name      = "beacon"
    proxmox_desc              = ""
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "(Dein-SSH-Public-Key)"
    proxmox_cores             = 2
    proxmox_memory            = 2048
  },
  {
    proxmox_server_count      = 1
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 114
    proxmox_start_vmid        = 114
    proxmox_owner_prefix      = "nvm"
    proxmox_service_name      = "vox"
    proxmox_desc              = ""
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "(Dein-SSH-Public-Key)"
    proxmox_cores             = 2
    proxmox_memory            = 2048
  }
]

servers_hetzner = [
]
