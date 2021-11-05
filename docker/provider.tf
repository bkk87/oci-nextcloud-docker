# Set the required provider and versions
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# Configure the docker provider
provider "docker" {
  host = "ssh://${var.docker_daemon_host}"
}
