output "instance_public_ip" {
  value = "127.0.0.1"
}

output "instance_private_ip" {
  value = local.instance_private_ip
}

output "ssh_user" {
  value = var.ssh_user
}

output "app_port" {
  value = var.app_port
}

output "db_public_ip" {
  value = "127.0.0.1"
}

output "db_private_ip" {
  value = local.db_private_ip
}

output "db_ssh_port" {
  value = var.db_ssh_port
}
