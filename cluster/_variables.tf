variable "name" {
  type        = string
  description = "The name of the kubernetes environment."
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "The list of SSH keys used to enable authentication to the nodes."
}

variable "image" {
  type        = string
  default     = "centos-cloud/centos-7"
  description = "The image to use for the nodes."
}

variable "masters" {
  type        = number
  default     = 1
  description = "The number of master nodes to create."
}

variable "workers" {
  type        = number
  default     = 1
  description = "The number of worker nodes to create."
}

variable "cpu" {
  type        = number
  default     = 2
  description = "The number of CPUs to allocate to each node."
}

variable "memory" {
  type        = number
  default     = 4096
  description = "The amount of memory to allocate to each node."
}

variable "public" {
  type        = bool
  default     = false
  description = "A value indicating whether or not to expose the kubernetes master API server on the public internet."
}

variable "cidr_blocks" {
  type = object({
    nodes    = string
    pods     = string
    services = string
  })

  default = {
    nodes    = "192.168.0.0/24"
    pods     = "172.16.0.0/16"
    services = "172.17.0.0/16"
  }

  description = "The CIDR blocks to use for the nodes, pods, and services."
}

locals {
  image_parts   = split("/", var.image)
  image_name    = length(local.image_parts) == 1 ? local.image_parts[0] : null
  image_project = length(local.image_parts) == 2 ? local.image_parts[0] : null
  image_family  = length(local.image_parts) == 2 ? local.image_parts[1] : null

  cloud_init         = file("${path.module}/cloud-init.cfg")
  cloud_init_kubectl = templatefile("${path.module}/cloud-init-kubectl.cfg", { version = var.wkp_version })

  zone = data.google_compute_zones.available.names[0]

  qualified_name = trim(lower(replace(var.name, "/[[:punct:]]|[[:space:]]/", "-")), "-")

  masters = [for i in range(var.masters) : "${local.qualified_name}-master-${format("%02d", i + 1)}"]
  workers = [for i in range(var.workers) : "${local.qualified_name}-worker-${format("%02d", i + 1)}"]

  public_key = tls_private_key.nodes.public_key_openssh
}
