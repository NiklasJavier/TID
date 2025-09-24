variable "hcloud_firewall_name" {
  description = "Name of the Hetzner Firewall"
  type        = string
  default     = "NV-FwTMg"
}

variable "hcloud_firewall_rules" {
  description = "List of firewall rules to apply"
  type = list(object({
    direction  = string
    protocol   = string
    port       = string
    source_ips = list(string)
  }))
  default = [
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

variable "hcloud_network_name" {
  description = "Name of the Hetzner Network"
  type        = string
  default     = "NV-NetTMg"
}

variable "hcloud_network_ip_range" {
  description = "IP Range for the Hetzner Network"
  type        = string
  default     = "172.16.0.0/12"
}

variable "hcloud_subnet_network_zone" {
  description = "Network zone of the subnet"
  type        = string
  default     = "eu-central"
}

variable "hcloud_subnet_ip_range" {
  description = "Subnet IP range"
  type        = string
  default     = "172.16.245.0/24"
}

variable "hcloud_route_destination" {
  description = "Route destination"
  type        = string
  default     = "0.0.0.0/0"
}

variable "hcloud_route_gateway" {
  description = "Route gateway IP"
  type        = string
  default     = "172.16.245.1"
}

variable "hcloud_datacenter" {
  description = "Hetzner Datacenter location"
  type        = string
  default     = "fsn1-dc14"
}

variable "hcloud_service_name" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "NV-ServerTMg"
}

variable "hcloud_server_type" {
  description = "Server type"
  type        = string
  default     = "cx11"
}

variable "hcloud_image" {
  description = "Image to use"
  type        = string
  default     = "ubuntu-20.04"
}

variable "hcloud_server_base_ip" {
  type    = string
  default = "172.16.245."
}

variable "hcloud_server_start_ip" {
  type    = number
  default = 10
}

variable "hcloud_server_private_ip" {
  description = "Primary private IP for the server"
  type        = string
  default     = "172.16.245.10"
}

variable "hcloud_server_alias_ips" {
  description = "Alias IPs for the server"
  type        = list(string)
  # bspw. default     = ["172.16.245.11", "172.16.245.12"]
  default = []
}

variable "hcloud_server_user_data_file" {
  description = "Path to the user data script"
  type        = string
  default     = "scripts/hetzner/snippets/init-zerotier.yaml"
}

variable "hcloud_server_labels" {
  description = "Labels for the server"
  type        = map(string)
  default = {
    "test" = "demo"
  }
}

variable "hcloud_enable_ipv4" {
  description = "Enable IPv4 on the server"
  type        = bool
  default     = false
}

variable "hcloud_enable_ipv6" {
  description = "Enable IPv6 on the server"
  type        = bool
  default     = true
}

variable "hcloud_server_count" {
  type    = number
  default = 1
}
variable "hcloud_owner_prefix" {
  type    = string
  default = "NV"
}


