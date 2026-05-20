locals {
  firewall_wan_ip = "172.30.10.254"
  firewall_dmz_ip = "172.30.20.254"
  adversary_ip    = "172.30.10.10"
}

resource "docker_network" "wan" {
  name = "${var.project_name}-wan"

  ipam_config {
    subnet = var.wan_subnet
  }
}

resource "docker_network" "dmz" {
  name = "${var.project_name}-dmz"

  ipam_config {
    subnet = var.dmz_subnet
  }
}

resource "docker_image" "firewall" {
  name = "${var.project_name}-firewall:latest"

  build {
    context = "${path.module}/../docker/firewall"
  }
}

resource "docker_image" "target" {
  name = "${var.project_name}-target:latest"

  build {
    context = "${path.module}/../docker/target"
  }
}

resource "docker_image" "adversary" {
  name = "${var.project_name}-adversary:latest"

  build {
    context = "${path.module}/../docker/adversary"
  }
}

resource "docker_container" "firewall" {
  name     = "${var.project_name}-firewall"
  hostname = "${var.project_name}-firewall"
  image    = docker_image.firewall.image_id
  must_run = true
  restart  = "unless-stopped"

  privileged = true

  capabilities {
    add = ["NET_ADMIN", "NET_RAW"]
  }

  sysctls = {
    "net.ipv4.ip_forward" = "1"
  }

  env = [
    "FIREWALL_MODE=detect",
    "WAN_NET=${var.wan_subnet}",
    "DMZ_NET=${var.dmz_subnet}",
    "TARGET_IP=${var.target_ip}"
  ]

  networks_advanced {
    name         = docker_network.wan.name
    ipv4_address = local.firewall_wan_ip
  }

  networks_advanced {
    name         = docker_network.dmz.name
    ipv4_address = local.firewall_dmz_ip
  }
}

resource "docker_container" "target" {
  name     = "${var.project_name}-target"
  hostname = "${var.project_name}-target"
  image    = docker_image.target.image_id
  must_run = true
  restart  = "unless-stopped"

  capabilities {
    add = ["NET_ADMIN"]
  }

  env = [
    "WAN_NET=${var.wan_subnet}",
    "FIREWALL_DMZ_IP=${local.firewall_dmz_ip}"
  ]

  networks_advanced {
    name         = docker_network.dmz.name
    ipv4_address = var.target_ip
  }

  depends_on = [docker_container.firewall]
}

resource "docker_container" "adversary" {
  name     = "${var.project_name}-adversary"
  hostname = "${var.project_name}-adversary"
  image    = docker_image.adversary.image_id
  must_run = true
  restart  = "unless-stopped"
  command  = ["sleep", "infinity"]

  capabilities {
    add = ["NET_ADMIN", "NET_RAW"]
  }

  env = [
    "TARGET_IP=${var.target_ip}",
    "FIREWALL_WAN_IP=${local.firewall_wan_ip}",
    "DMZ_NET=${var.dmz_subnet}"
  ]

  networks_advanced {
    name         = docker_network.wan.name
    ipv4_address = local.adversary_ip
  }

  depends_on = [docker_container.firewall, docker_container.target]
}

