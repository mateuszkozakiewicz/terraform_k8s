variable "cluster_domain" { default = "" }

resource "google_dns_managed_zone" "external_dns_cluster_zone" {
  name     = "external-dns-cluster-zone"
  dns_name = var.cluster_domain
}

output "dns_nameservers" {
  value       = google_dns_managed_zone.external_dns_cluster_zone.name_servers
  description = "Namserver records to set in domain provider"
}
