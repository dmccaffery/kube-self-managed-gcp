data "google_client_config" "current" {
}

data "google_client_openid_userinfo" "current" {
}

data "google_compute_zones" "available" {
}

data "google_compute_image" "node" {
  name    = local.image_name
  family  = local.image_family
  project = local.image_project
}
