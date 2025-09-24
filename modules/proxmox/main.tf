terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

####################################################
# Server
####################################################
resource "proxmox_vm_qemu" "server" {
  count       = var.proxmox_server_count
  name        = "${var.proxmox_owner_prefix}sys-${format("%03d", var.proxmox_server_start_ip + count.index)}-${var.proxmox_service_name}"
  vmid        = var.proxmox_start_vmid + count.index
  desc        = var.proxmox_desc
  target_node = var.proxmox_target_node
  sshkeys     = var.proxmox_sshkeys
  agent       = 1
  clone       = var.proxmox_clone_template
  qemu_os     = var.proxmox_qemu_os
  ssh_user    = "terraform"
  cores       = var.proxmox_cores
  sockets     = 1
  cpu_type    = var.proxmox_cpu
  memory      = var.proxmox_memory
  scsihw      = var.proxmox_scsihw
  vm_state    = "running"
  cicustom    = join(",", var.proxmox_cicustom_snippets)
  ciupgrade   = true
  skip_ipv6   = true
  os_type     = var.proxmox_cloud_init_os_type
  ipconfig0   = "ip=${var.proxmox_server_base_ip}${var.proxmox_server_start_ip + count.index}/24,gw=10.15.1.2"
  nameserver  = var.proxmox_cloud_init_nameserver
  ciuser      = var.proxmox_cloud_init_ciuser
  cipassword  = var.proxmox_cloud_init_ciuser_password

  vga {
    type = "std"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.proxmox_disk_storage
          size    = var.proxmox_disk_size
          discard = true
          backup  = true
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.proxmox_disk_storage
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  ####################################################
  # Network
  ####################################################
  network {
    id     = 0
    bridge = var.proxmox_network_bridge
    model  = var.proxmox_network_model
  }
}

