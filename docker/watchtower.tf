data "docker_registry_image" "watchtower" {
  name = "containrrr/watchtower:latest"
}
resource "docker_image" "watchtower" {
  name         = data.docker_registry_image.watchtower.name
  keep_locally = true
}

resource "docker_container" "watchtower" {
  name   = "watchtower"
  image  = docker_image.watchtower.name
  memory = var.watchtower_container_memory_limit
  env = [
    "WATCHTOWER_CLEANUP=true",
    "WATCHTOWER_POLL_INTERVAL=21600", #6 hours
    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  ]
  restart = "unless-stopped"
  start   = true
  mounts {
    target    = "/etc/timezone"
    source    = "/etc/timezone"
    type      = "bind"
    read_only = true
  }
  mounts {
    target    = "/var/run/docker.sock"
    source    = "/var/run/docker.sock"
    type      = "bind"
    read_only = false
  }
  networks_advanced {
    name = docker_network.private_with_outbound.name
  }
  ipc_mode = "private"
  labels {
    label = "com.centurylinklabs.watchtower"
    value = "true"
  }
}

