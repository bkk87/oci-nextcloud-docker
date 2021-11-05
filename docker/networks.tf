resource "docker_network" "private_with_outbound" {
  name            = "private_with_outbound"
  check_duplicate = true
  driver          = "bridge"
  ipam_config {
    subnet   = "172.20.0.0/16"
    ip_range = "172.20.0.0/24"
    gateway  = "172.20.0.1"
  }
  options = {
    "com.docker.network.bridge.name"                 = "docker1",
    "com.docker.network.bridge.enable_ip_masquerade" = "true",
    "com.docker.network.bridge.enable_icc"           = "true",
    "com.docker.network.bridge.host_binding_ipv4"    = "127.0.0.1"
    "com.docker.network.driver.mtu"                  = "1500"
  }
}

resource "docker_network" "public_with_outbound" {
  name            = "public_with_outbound"
  check_duplicate = true
  driver          = "bridge"
  ipam_config {
    subnet   = "172.19.0.0/16"
    ip_range = "172.19.0.0/24"
    gateway  = "172.19.0.1"
  }
  options = {
    "com.docker.network.bridge.name"                 = "docker2",
    "com.docker.network.bridge.enable_ip_masquerade" = "true",
    "com.docker.network.bridge.enable_icc"           = "true",
    "com.docker.network.bridge.host_binding_ipv4"    = "0.0.0.0"
    "com.docker.network.driver.mtu"                  = "1500"
  }
}

