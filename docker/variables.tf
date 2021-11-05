# provider

variable "docker_daemon_host" {
  default     = "oci"
  description = "ip/hostname of the (remote) docker daemon"
}

# traefik

variable "user_digest_auth" {
  type        = string
  description = "htdigest -c htdigestfile traefik myusername"
}
variable "letsencrypt_email" {
  type    = string
  default = "myemail@domain.com"
}
variable "traefik_container_memory_limit" {
  type    = number
  default = 512
}

# nextcloud

variable "domain_name1" {
  type    = string
  default = "myserver.duckdns.org"
}
variable "nextcloud_admin_username" {
  type    = string
  default = "admin"
}

variable "nextloud_php_mem_limit" {
  type    = string
  default = "7680M"
}

variable "nextloud_php_upload_limit" {
  type    = string
  default = "20G"
}

variable "nextloud_container_memory_limit" {
  type    = number
  default = 8192
}

# mariadb

variable "mariadb_container_memory_limit" {
  type    = number
  default = 1024
}

# redis

variable "redis_container_memory_limit" {
  type    = number
  default = 256
}

# watchtower

variable "watchtower_container_memory_limit" {
  type    = number
  default = 128
}


