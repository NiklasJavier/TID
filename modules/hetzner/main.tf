terraform {
  required_version = ">= 1.10.0"

  required_providers {
    # https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.45"
    }
  }
}

####################################################
# Firewall
####################################################
resource "hcloud_firewall" "firewall" {
  name = "${var.hcloud_owner_prefix}ipfw-${var.hcloud_service_name}"

  dynamic "rule" {
    for_each = var.hcloud_firewall_rules
    content {
      direction  = rule.value.direction
      protocol   = rule.value.protocol
      port       = rule.value.port
      source_ips = rule.value.source_ips
    }
  }
}

####################################################
# Network
####################################################

resource "hcloud_network" "network" {
  name     = "${var.hcloud_owner_prefix}net-${var.hcloud_service_name}"
  ip_range = var.hcloud_network_ip_range
}

resource "hcloud_network_subnet" "network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.hcloud_subnet_network_zone
  ip_range     = var.hcloud_subnet_ip_range
}

resource "hcloud_network_route" "privNet" {
  network_id  = hcloud_network.network.id
  destination = var.hcloud_route_destination
  gateway     = var.hcloud_route_gateway
}

####################################################
# Server
####################################################
resource "hcloud_server" "server" {
  count        = var.hcloud_server_count
  name         = "${var.hcloud_owner_prefix}sys-${format("%03d", count.index)}-${var.hcloud_service_name}"
  server_type  = var.hcloud_server_type
  image        = var.hcloud_image
  firewall_ids = [hcloud_firewall.firewall.id]
  datacenter   = var.hcloud_datacenter
  user_data = file(var.hcloud_server_user_data_file)

  labels = var.hcloud_server_labels

  public_net {
    ipv4_enabled = var.hcloud_enable_ipv4
    ipv6_enabled = var.hcloud_enable_ipv6
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "${var.hcloud_server_base_ip}${var.hcloud_server_start_ip + count.index}"
    alias_ips  = var.hcloud_server_alias_ips
  }

  depends_on = [
    hcloud_network.network,
    hcloud_network_subnet.network_subnet,
    hcloud_network_route.privNet,
    hcloud_firewall.firewall
  ]
}
