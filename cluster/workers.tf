resource "google_compute_instance" "worker" {
  for_each = toset(local.workers)
  name     = each.key
  zone     = local.zone

  machine_type              = "custom-${var.cpu}-${var.memory}"
  can_ip_forward            = true
  allow_stopping_for_update = true

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  network_interface {
    network    = google_compute_network.net.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata = {
    enable-oslogin = "FALSE"
    ssh-keys       = "kube-admin:${local.public_key}"
    user-data      = data.template_cloudinit_config.worker.rendered
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"
    ]
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = data.google_compute_image.node.self_link
      size  = 30
    }
  }

  tags = ["ssh", "kube-node", "kube-worker"]
}

data "template_cloudinit_config" "worker" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}
