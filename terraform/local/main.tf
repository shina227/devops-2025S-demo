terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Uses DOCKER_HOST, e.g. export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
provider "docker" {}

locals {
  instance_private_ip = cidrhost(var.subnet, 10)
  db_private_ip       = cidrhost(var.subnet, 20)
}

# The "VPC": a private network the two servers share
resource "docker_network" "campus" {
  name = "campus-notifier-net"
  ipam_config {
    subnet = var.subnet
  }
}

# The "AMI": a bare Ubuntu image with SSH
resource "docker_image" "server" {
  name = "campus-notifier-server:latest"
  build {
    context = "${path.module}/server"
  }
  triggers = {
    dockerfile = filesha1("${path.module}/server/Dockerfile")
    entrypoint = filesha1("${path.module}/server/entrypoint.sh")
  }
}

# Docker's data lives here so the app server can run containers inside itself
resource "docker_volume" "app_docker_data" {
  name = "campus-notifier-app-docker"
}

# App server. Privileged so Docker can be installed and run inside it.
resource "docker_container" "app" {
  name       = "campus-notifier-app"
  hostname   = "app-server"
  image      = docker_image.server.image_id
  privileged = true
  restart    = "unless-stopped"
  env        = ["SSH_PUBLIC_KEY=${trimspace(file(pathexpand(var.ssh_public_key_path)))}"]

  networks_advanced {
    name         = docker_network.campus.id
    ipv4_address = local.instance_private_ip
  }

  ports {
    internal = 22
    external = var.instance_ssh_port
  }

  ports {
    internal = var.app_port
    external = var.app_port
  }

  volumes {
    volume_name    = docker_volume.app_docker_data.name
    container_path = "/var/lib/docker"
  }
}

# Database server. Only SSH is published; Postgres is reachable on the private network only.
resource "docker_container" "db" {
  name     = "campus-notifier-db"
  hostname = "db-server"
  image    = docker_image.server.image_id
  restart  = "unless-stopped"
  env      = ["SSH_PUBLIC_KEY=${trimspace(file(pathexpand(var.ssh_public_key_path)))}"]

  networks_advanced {
    name         = docker_network.campus.id
    ipv4_address = local.db_private_ip
  }

  ports {
    internal = 22
    external = var.db_ssh_port
  }
}
