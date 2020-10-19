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

variable "wkp_version" {
  type        = string
  default     = "master"
  description = "The branch and short git SHA of the version to retrieve from S3."
}

variable "docker_credentials" {
  type = object({
    username = string
    password = string
  })
  description = <<-EOT
    The docker hub username and password required to authenticate to docker hub.
    RECOMMENDATION: It is highly recommended to set the password via an environment variable:
      TF_VAR_DOCKER_CREDENTIALS='{ username = "username", password = "password" }'
  EOT
}

variable "entitlements_file" {
  type        = string
  default     = "~/.wks/entitlements"
  description = <<-EOT
    The path to the wkp entitlements file.
    DEFAULT: "~/.wks/entitlements"
  EOT
}

variable "kubernetes_version" {
  type        = string
  default     = "1.16.11"
  description = "The version of kubernetes to install using wkp."
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
  qualified_name = trim(lower(replace(var.name, "/[[:punct:]]|[[:space:]]/", "-")), "-")
}
