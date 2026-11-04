variable "my_ip_cidr" {
  type        = string
  description = "Your public IP. Unused on the local track (everything is on localhost), kept so the cloud-track commands still work."
  default     = "127.0.0.1/32"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/alu-devops.pub"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "instance_ssh_port" {
  type        = number
  description = "Host port for SSH to the app server"
  default     = 22
}

variable "db_ssh_port" {
  type        = number
  description = "Host port for SSH to the database server"
  default     = 2223
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "subnet" {
  type    = string
  default = "172.30.0.0/24"
}
