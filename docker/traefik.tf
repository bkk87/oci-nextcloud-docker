data "docker_registry_image" "traefik" {
  name = "traefik:latest"
}
resource "docker_image" "traefik" {
  name         = data.docker_registry_image.traefik.name
  keep_locally = true
}

resource "docker_volume" "traefik_data_letsencrypt" {
  name   = "traefik_data_letsencrypt"
  driver = "local"
}

resource "docker_container" "traefik" {
  name     = "traefik"
  image    = docker_image.traefik.name
  memory   = var.traefik_container_memory_limit
  restart  = "unless-stopped"
  must_run = false
  start    = true
  dns      = ["1.1.1.1"]
  command = [
    "--certificatesresolvers.myresolver.acme.email=${var.letsencrypt_email}",
    "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json",
    "--certificatesresolvers.myresolver.acme.tlschallenge=true",
    "--providers.docker.exposedByDefault=false",
    "--api=false",
    "--api.dashboard=false",
    "--metrics.prometheus=false",
    "--metrics.prometheus.manualrouting=false",
    "--providers.docker",
    "--providers.docker.network=${docker_network.public_with_outbound.name}",
    "--log.level=INFO",
    "--entryPoints.http.address=:80",
    "--entryPoints.https.address=:443",
    "--entryPoints.internal.address=:8082"
  ]
  mounts {
    target    = "/var/run/docker.sock"
    source    = "/var/run/docker.sock"
    type      = "bind"
    read_only = true
  }
  mounts {
    target = "/letsencrypt"
    type   = "volume"
    source = docker_volume.traefik_data_letsencrypt.name
  }

  ports {
    internal = 80
    external = 80
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
  ports {
    internal = 443
    external = 443
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  networks_advanced {
    name = docker_network.public_with_outbound.name
  }

  ipc_mode = "private"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.middlewares.auth.digestauth.users"
    value = var.user_digest_auth
  }
  labels {
    label = "traefik.http.middlewares.ratelimit.ratelimit.average"
    value = "10"
  }
  labels {
    label = "traefik.http.middlewares.ratelimit.ratelimit.burst"
    value = "100"
  }
  # labels {
  #   label = "traefik.http.routers.api.entrypoints"
  #   value = "internal"
  # }
  # labels {
  #   label = "traefik.http.routers.prometheus.entrypoints"
  #   value = "internal"
  # }
  # labels {
  #   label = "traefik.http.routers.dashboard.entrypoints"
  #   value = "internal"
  # }
  # labels {
  #   label = "traefik.http.routers.api.middlewares"
  #   value = "auth@docker,ratelimit@docker"
  # }
  # labels {
  #   label = "traefik.http.routers.prometheus.middlewares"
  #   value = "ratelimit@docker"
  # }
  # labels {
  #   label = "traefik.http.routers.dashboard.middlewares"
  #   value = "auth@docker,ratelimit@docker"
  # }
  # labels {
  #   label = "traefik.http.routers.api.service"
  #   value = "api@internal"
  # }
  # labels {
  #   label = "traefik.http.routers.prometheus.service"
  #   value = "prometheus@internal"
  # }
  # labels {
  #   label = "traefik.http.routers.dashboard.service"
  #   value = "api@internal"
  # }
  # labels {
  #   label = "traefik.http.routers.api.rule"
  #   value = "Host(`${var.internal_domain_name}`) && (PathPrefix(`/api`))"
  # }
  # labels {
  #   label = "traefik.http.routers.prometheus.rule"
  #   value = "PathPrefix(`/metrics`)"
  # }
  # labels {
  #   label = "traefik.http.routers.dashboard.rule"
  #   value = "Host(`${var.internal_domain_name}`) && (PathPrefix(`/dashboard`))"
  # }
}




