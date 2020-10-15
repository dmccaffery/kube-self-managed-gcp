variable "name" {
  type        = string
  description = "The name of the kubernetes environment."
}

variable "project" {
  type        = string
  description = <<-EOT
    The project in which to create resources. To see a list of projects you have access to use
    `gcloud projects list`.
  EOT
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = <<-EOT
    The compute region in which to create the resources, such as `europe-west2`. use `gcloud compute regions list`
    to get a complete list.
  EOT
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
  services = [
    "cloudshell.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudfunctions.googleapis.com"
  ]

  qualified_name = trim(lower(replace(var.name, "/[[:punct:]]|[[:space:]]/", "-")), "-")
}
