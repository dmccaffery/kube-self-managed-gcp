terraform {
  required_version = "~> 0.13.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.43"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "backend" {
  name          = "${local.qualified_name}-terraform-backend"
  location      = var.region
  storage_class = "REGIONAL"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  force_destroy = true
}

resource "local_file" "backend" {
  content         = <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.backend.name}"
      }
    }
  EOT
  filename        = "${path.module}/backend.tf"
  file_permission = "0644"

  depends_on = [
    google_storage_bucket.backend
  ]
}
