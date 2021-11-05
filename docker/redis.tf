data "docker_registry_image" "redis" {
  name = "redis:6"
}
resource "docker_image" "redis" {
  name         = data.docker_registry_image.redis.name
  keep_locally = true
}

resource "docker_volume" "redis_data" {
  name   = "redis_data"
  driver = "local"
  driver_opts = {
    "type"   = "tmpfs",
    "device" = "tmpfs",
    "o"      = "size=64m"
  }
}

resource "docker_container" "redis" {
  name    = "redis"
  image   = docker_image.redis.name
  memory  = var.redis_container_memory_limit
  restart = "unless-stopped"
  start   = true
  mounts {
    target = "/data"
    type   = "volume"
    source = docker_volume.redis_data.name
  }
  networks_advanced {
    name = docker_network.private_with_outbound.name
  }
  ipc_mode = "private"
}

