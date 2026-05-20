output "lab_summary" {
  value = {
    firewall = {
      container = docker_container.firewall.name
      wan_ip    = local.firewall_wan_ip
      dmz_ip    = local.firewall_dmz_ip
    }
    target = {
      container = docker_container.target.name
      ip        = var.target_ip
    }
    adversary = {
      container = docker_container.adversary.name
      ip        = local.adversary_ip
    }
  }
}

