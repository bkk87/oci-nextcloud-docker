data "docker_registry_image" "mariadb" {
  name = "mariadb:10.5"
}

resource "docker_image" "mariadb" {
  name         = data.docker_registry_image.mariadb.name
  keep_locally = true
}

resource "docker_volume" "mariadb" {
  name   = "mariadb_data"
  driver = "local"
}

resource "random_password" "mariadb_password" {
  length  = 20
  special = false
}
resource "random_password" "mariadb_nextcloud_password" {
  length  = 20
  special = false
}

resource "docker_container" "mariadb" {
  name   = "mariadb"
  image  = docker_image.mariadb.name
  memory = var.mariadb_container_memory_limit
  env = [
    "MARIADB_ROOT_PASSWORD=${random_password.mariadb_password.result}"
  ]
  restart = "unless-stopped"
  start   = true
  mounts {
    target    = "/var/lib/mysql"
    type      = "volume"
    source    = docker_volume.mariadb.name
    read_only = false
  }
  networks_advanced {
    name = docker_network.private_with_outbound.name
  }
  ipc_mode = "private"
}

