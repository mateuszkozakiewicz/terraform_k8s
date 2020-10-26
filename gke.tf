variable "project_name" { default = "" }
variable "region" { default = "" }

variable "cluster_name" { default = "default-cluster" }
variable "cluster_username" { default = "admin" }


resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  #network    = google_compute_network.vpc.name
  #subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    username = var.cluster_username
    password = random_password.cluster_password.result

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

variable "node_pool_name" { default = "default-node-pool" }
variable "node_machine_type" { default = "g1-small" }
variable "node_count" { default = 3 }

resource "google_container_node_pool" "primary_nodes" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.node_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.region}"
  }

  # Wait for the cluster to fully come up before proceeding
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "random_password" "cluster_password" {
  length  = 32
  special = true
}

output "username" {
  value       = var.cluster_username
  description = "Cluster username"
}

output "password" {
  value       = random_password.cluster_password.result
  description = "Cluster password"
}

output "cluster_name" {
  value       = var.cluster_name
  description = "Cluster name"
}

output "cluster_zone" {
  value       = var.region
  description = "Cluster zone"
}

output "cluster_ip" {
  value       = google_container_cluster.primary.endpoint
  description = "Cluster endpoint"
}
