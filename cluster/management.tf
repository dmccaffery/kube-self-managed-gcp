data "google_compute_image" "management" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_service_account" "management" {
  account_id   = "${local.qualified_name}-management"
  display_name = "${local.qualified_name}-management"
}

resource "google_project_iam_member" "admin" {
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.management.email}"
}

resource "google_compute_instance" "management" {
  name = "${local.qualified_name}-management"
  zone = local.zone

  machine_type              = "custom-2-4096"
  can_ip_forward            = true
  allow_stopping_for_update = true

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = false
  }

  network_interface {
    network    = google_compute_network.net.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link

    access_config {
    }
  }

  metadata = {
    enable-oslogin = "FALSE"
    ssh-keys       = join("\n", [for key in concat(var.ssh_keys, [local.public_key]) : "kube-admin:${key}"])
    user-data      = data.template_cloudinit_config.management.rendered
  }

  service_account {
    email  = google_service_account.management.email
    scopes = ["userinfo-email", "cloud-platform"]
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = data.google_compute_image.management.self_link
      size  = 30
    }
  }

  provisioner "file" {
    content     = tls_private_key.nodes.private_key_pem
    destination = "/home/kube-admin/.ssh/id_ecdsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u=rw,go= /home/kube-admin/.ssh/id_ecdsa"
    ]
  }

  connection {
    type        = "ssh"
    user        = "kube-admin"
    private_key = tls_private_key.nodes.private_key_pem
    host        = self.network_interface[0].access_config[0].nat_ip
  }

  tags = ["ssh"]
}

data "template_cloudinit_config" "management" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }

  part {
    filename     = "cloud-init-kubectl.cfg"
    content_type = "text/cloud-config"
    content      = local.cloud_init_kubectl
  }
}
