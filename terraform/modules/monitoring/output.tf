output "grafana_url" {
  description = "Grafana internal URL (accessible within VPC)"
  value       = "https://grafana-${var.cluster_name}.${var.domain_name}"
}
