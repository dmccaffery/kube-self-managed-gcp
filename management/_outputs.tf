output "name" {
  value = google_compute_instance.management.name
}

output "internal_ip" {
  value = google_compute_instance.management.network_interface[0].network_ip
}

output "external_ip" {
  value = google_compute_instance.management.network_interface[0].access_config[0].nat_ip
}
