# resource "google_compute_network" "vpc" {
#   name                    = "${var.cluster_name}-vpc"
#   auto_create_subnetworks = "true"
# }

# resource "google_compute_subnetwork" "subnet" {
#   name          = "${var.project_name}-subnet"
#   region        = regex("\\w+-\\w+", var.region)
#   network       = google_compute_network.vpc.name
#   ip_cidr_range = "10.10.0.0/24"
# }
