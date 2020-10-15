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
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

resource "tls_private_key" "nodes" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}
