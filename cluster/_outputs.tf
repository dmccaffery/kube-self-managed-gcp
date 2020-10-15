output "name" {
  value = local.qualified_name
  depends_on = [
    google_compute_instance.management,
    google_compute_instance.master,
    google_compute_instance.worker
  ]
  description = "The qualified name used to create resources."
}

output "nodes" {
  value = {
    load_balancers = {
      api_server = google_compute_address.masters.address
    }

    management = {
      name        = google_compute_instance.management.name
      internal_ip = google_compute_instance.management.network_interface[0].network_ip
      external_ip = google_compute_instance.management.network_interface[0].access_config[0].nat_ip
    }

    masters = [for master in google_compute_instance.master : {
      name        = master.name
      internal_ip = master.network_interface[0].network_ip
    }]

    workers = [for worker in google_compute_instance.worker : {
      name        = worker.name
      internal_ip = worker.network_interface[0].network_ip
    }]
  }
  description = "The name and ip addresses of the management, master, and worker instances."
}

output "user" {
  value = {
    username = "kube-admin"
    ssh_keys = var.ssh_keys
  }
  depends_on = [
    google_compute_instance.management,
    google_compute_instance.master,
    google_compute_instance.worker
  ]
  description = "The public SSH keys that were configured in the management, master, and worker instances."
}
