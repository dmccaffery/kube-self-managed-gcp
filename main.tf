resource "google_project_service" "service" {
  for_each = toset(local.services)
  service  = each.key

  disable_on_destroy = false
}

resource "tls_private_key" "management" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

module "cluster" {
  source = "./cluster"

  name        = var.name
  ssh_keys    = [tls_private_key.management.public_key_openssh]
  image       = var.image
  masters     = var.masters
  workers     = var.workers
  cpu         = var.cpu
  memory      = var.memory
  cidr_blocks = var.cidr_blocks

  depends_on = [
    google_project_service.service
  ]
}

resource "local_file" "private-key" {
  content         = tls_private_key.management.private_key_pem
  filename        = pathexpand("~/.ssh/${var.name}-ecdsa-key")
  file_permission = "0600"

  depends_on = [
    google_storage_bucket.backend
  ]
}

resource "local_file" "public-key" {
  content         = tls_private_key.management.public_key_openssh
  filename        = pathexpand("~/.ssh/${var.name}-ecdsa-key.pub")
  file_permission = "0600"

  depends_on = [
    google_storage_bucket.backend
  ]
}
