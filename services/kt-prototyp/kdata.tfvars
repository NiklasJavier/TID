####################################################
# terraform init
# terraform plan -var-file="./services/kt-prototyp/kdata.tfvars"
# terraform apply -var-file="./services/kt-prototyp/kdata.tfvars"
# terraform destroy -var-file="./services/kt-prototyp/kdata.tfvars"
####################################################

servers_proxmox = [
  {
    proxmox_server_count      = 1
    proxmox_server_base_ip    = "10.15.1."
    proxmox_server_start_ip   = 192
    proxmox_start_vmid        = 1192
    proxmox_owner_prefix      = "NV"
    proxmox_service_name      = "kdata"
    proxmox_desc              = "für die KData-Plattform"
    proxmox_target_node       = "HFAL-PRX01"
    proxmox_cicustom_snippets = [
      "vendor=local:snippets/qemu-guest-agent.yml",
      "vendor=local:snippets/default.yml"
    ]
    proxmox_clone_template    = "ubuntu-focal-cloudinit"
    proxmox_sshkeys           = "(Dein-SSH-Public-Key)"
    proxmox_cores             = 4
    proxmox_memory            = 4096
  }
]

servers_hetzner = []
