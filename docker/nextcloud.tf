data "docker_registry_image" "nextcloud" {
  name = "nextcloud:stable"
}

resource "docker_image" "nextcloud" {
  name         = data.docker_registry_image.nextcloud.name
  keep_locally = true
}

resource "docker_volume" "nextcloud_data" {
  name   = "nextcloud_data"
  driver = "local"
}

resource "random_password" "nextcloud_password" {
  length  = 20
  special = false
}

# optimized preview configuration: https://ownyourbits.com/2019/06/29/understanding-and-improving-nextcloud-previews/
#docker exec --user www-data nextcloud php occ config:app:set previewgenerator squareSizes --value="32 256"
#docker exec --user www-data nextcloud php occ config:app:set previewgenerator widthSizes  --value="256 384"
#docker exec --user www-data nextcloud php occ config:app:set previewgenerator heightSizes --value="256"
#docker exec --user www-data nextcloud php occ config:system:set preview_max_x --value 2048
#docker exec --user www-data nextcloud php occ config:system:set preview_max_y --value 2048
#docker exec --user www-data nextcloud php occ config:system:set jpeg_quality --value 60
#docker exec --user www-data nextcloud php occ config:app:set preview jpeg_quality --value="60"

resource "docker_container" "nextcloud" {
  depends_on = [docker_container.mariadb, docker_container.redis]
  name       = "nextcloud"
  image      = docker_image.nextcloud.name
  memory     = var.nextloud_container_memory_limit
  restart    = "unless-stopped"
  dns        = ["1.1.1.1"]
  env = [
    "MYSQL_DATABASE=nextcloud",
    "MYSQL_USER=nextcloud",
    "MYSQL_PASSWORD=${random_password.mariadb_nextcloud_password.result}",
    "MYSQL_HOST=mariadb",
    "NEXTCLOUD_ADMIN_USER=${var.nextcloud_admin_username}",
    "NEXTCLOUD_ADMIN_PASSWORD=${random_password.nextcloud_password.result}",
    "NEXTCLOUD_TRUSTED_DOMAINS=${var.domain_name1}",
    "TRUSTED_PROXIES=172.19.0.0/24",
    "PHP_MEMORY_LIMIT=${var.nextloud_php_mem_limit}",
    "PHP_UPLOAD_LIMIT=${var.nextloud_php_upload_limit}",
    "REDIS_HOST=redis" #,
  ]

  mounts {
    target = "/var/www/html"
    type   = "volume"
    source = docker_volume.nextcloud_data.name
  }

  networks_advanced {
    name = docker_network.private_with_outbound.name
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
    label = "traefik.http.services.nextcloud.loadbalancer.server.port"
    value = "80"
  }
  labels {
    label = "traefik.http.routers.web-secure.entrypoints"
    value = "https"
  }
  labels {
    label = "traefik.http.routers.web-secure.middlewares"
    value = "ratelimit@docker,nc-rep@docker,nc-header@docker" #,auth@docker"
  }
  labels {
    label = "traefik.http.routers.web-secure.rule"
    value = "Host(`${var.domain_name1}`)"
  }
  labels {
    label = "traefik.http.routers.web-secure.service"
    value = "nextcloud@docker"
  }
  labels {
    label = "traefik.http.routers.web-secure.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.web-secure.tls.certresolver"
    value = "myresolver"
  }
  labels {
    label = "traefik.http.routers.web.entrypoints"
    value = "http"
  }
  labels {
    label = "traefik.http.routers.web.middlewares"
    value = "https-redirect"
  }
  labels {
    label = "traefik.http.routers.web.rule"
    value = "Host(`${var.domain_name1}`)"
  }
  labels {
    label = "traefik.http.middlewares.https-redirect.redirectscheme.scheme"
    value = "https"
  }
  labels {
    label = "traefik.http.middlewares.nc-rep.redirectregex.regex"
    value = "https://(.*)/.well-known/(card|cal)dav"
  }
  labels {
    label = "traefik.http.middlewares.nc-rep.redirectregex.replacement"
    value = "https://$1/remote.php/dav/"
  }
  labels {
    label = "traefik.http.middlewares.nc-rep.redirectregex.permanent"
    value = "true"
  }
  labels {
    label = "traefik.http.middlewares.nc-header.headers.customFrameOptionsValue"
    value = "SAMEORIGIN"
  }
  labels {
    label = "traefik.http.middlewares.nc-header.headers.stsSeconds"
    value = "31536000"
  }
  labels {
    label = "traefik.http.middlewares.nc-header.headers.forceSTSHeader"
    value = "true"
  }
  labels {
    label = "traefik.http.middlewares.nc-header.headers.stsPreload"
    value = "true"
  }
  labels {
    label = "traefik.http.middlewares.nc-header.headers.stsIncludeSubdomains"
    value = "true"
  }
}

