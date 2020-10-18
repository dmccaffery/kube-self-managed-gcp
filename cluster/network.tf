resource "google_compute_network" "net" {
  name                    = "${local.qualified_name}-net"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name   = "${local.qualified_name}-subnet"
  region = data.google_client_config.current.region

  ip_cidr_range = var.cidr_blocks.nodes
  network       = google_compute_network.net.self_link

  secondary_ip_range {
    range_name    = "${local.qualified_name}-pods"
    ip_cidr_range = var.cidr_blocks.pods
  }

  secondary_ip_range {
    range_name    = "${local.qualified_name}-services"
    ip_cidr_range = var.cidr_blocks.services
  }
}

resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "icmp" {
  name    = "${var.name}-allow-icmp"
  network = google_compute_network.net.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-allow-ssh"
  network = google_compute_network.net.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = ["ssh"]
}

resource "google_compute_firewall" "nodes" {
  name    = "${var.name}-allow-kube-services"
  network = google_compute_network.net.self_link

  allow {
    protocol = "tcp"
    ports = [
      "2379-2380", # etcd
      "6783-6784", # weave-net
      "10250"      # container logs
    ]
  }

  source_tags = ["kube-node"]
  target_tags = ["kube-node"]
}

resource "google_compute_firewall" "health-checks" {
  name    = "${var.name}-allow-health-checks"
  network = google_compute_network.net.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
  target_tags = ["kube-node"]
}

resource "google_compute_firewall" "masters-load-balancer" {
  name    = "${var.name}-allow-kube-api-server"
  network = google_compute_network.net.self_link

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]

  target_tags = ["kube-node"]
}
