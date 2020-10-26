data "google_client_config" "provider" {}

provider "google" {
  credentials = file("account.json")
  project     = var.project_name
  region      = var.region
}

provider "kubernetes" {
  load_config_file = false
  host             = "https://${google_container_cluster.primary.endpoint}"
  username         = var.cluster_username
  password         = random_password.cluster_password.result

  # token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
  client_certificate = base64decode(google_container_cluster.primary.master_auth[0].client_certificate)
  client_key         = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  # cluster_ca_certificate = "${base64decode(module.Web-Cluster.cluster_ca_certificate)}"
}

provider "kubectl" {
  host     = "https://${google_container_cluster.primary.endpoint}"
  username = var.cluster_username
  password = random_password.cluster_password.result
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
  client_certificate = base64decode(google_container_cluster.primary.master_auth[0].client_certificate)
  client_key         = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  load_config_file   = false
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
