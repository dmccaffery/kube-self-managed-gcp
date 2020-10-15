resource "google_compute_instance" "master" {
  for_each = toset(local.masters)
  name     = each.key
  zone     = local.zone

  machine_type              = "custom-2-4096"
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
    user-data      = data.template_cloudinit_config.master.rendered
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

  tags = ["ssh", "kube-node", "kube-master"]
}

resource "google_compute_http_health_check" "masters" {
  name = "${local.qualified_name}-masters"

  request_path = "/livez"
  port         = 6443
}

resource "google_compute_target_pool" "masters" {
  name = "${local.qualified_name}-masters"

  instances = [for master in google_compute_instance.master : master.self_link]

  health_checks = [
    google_compute_http_health_check.masters.self_link
  ]
}

resource "google_compute_address" "masters" {
  name         = "${local.qualified_name}-masters"
  address_type = "EXTERNAL"
}

resource "google_compute_forwarding_rule" "masters" {
  name = "${local.qualified_name}-masters"

  target = google_compute_target_pool.masters.self_link

  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.masters.address
  ip_protocol           = "TCP"
  port_range            = "6443"
}

data "template_cloudinit_config" "master" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}
