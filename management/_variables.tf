variable "name" {
  type        = string
  description = "The name of the kubernetes environment."
}

variable "user" {
  type = object({
    username        = string
    id_ecdsa        = string
    authorized_keys = list(string)
  })

  description = "The user credentials used to login to the management node."
}

variable "cloud_init" {
  type = list(object({
    filename     = string
    content_type = string
    content      = string
  }))
  default     = []
  description = "Additional cloud-init scripts to incorporate in the management node."
}

variable "script" {
  type        = string
  default     = null
  description = "The script to execute as the user created on the system."
}

locals {
  cloud_init         = templatefile("${path.module}/cloud-init.cfg", merge({ name = var.name }, var.user))
  cloud_init_kubectl = file("${path.module}/cloud-init-kubectl.cfg")
}
