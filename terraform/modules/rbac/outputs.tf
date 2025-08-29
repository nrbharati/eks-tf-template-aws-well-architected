output "cluster_admin_service_account_name" {
  description = "Name of the cluster admin service account"
  value       = kubernetes_service_account.cluster_admin.metadata[0].name
}

output "cluster_admin_service_account_namespace" {
  description = "Namespace of the cluster admin service account"
  value       = kubernetes_service_account.cluster_admin.metadata[0].namespace
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
} 