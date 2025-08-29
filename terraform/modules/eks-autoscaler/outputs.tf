# Outputs for EKS Auto Mode Module

output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IAM role"
  value       = var.enable_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

output "cluster_autoscaler_role_name" {
  description = "Name of the Cluster Autoscaler IAM role"
  value       = var.enable_autoscaler ? aws_iam_role.cluster_autoscaler[0].name : null
}

output "cluster_autoscaler_policy_arn" {
  description = "ARN of the Cluster Autoscaler IAM policy"
  value       = var.enable_autoscaler ? aws_iam_policy.cluster_autoscaler[0].arn : null
}

output "autoscaler_enabled" {
  description = "Whether Cluster Autoscaler is enabled"
  value       = var.enable_autoscaler
}

output "helm_release_name" {
  description = "Name of the Cluster Autoscaler Helm release"
  value       = var.enable_autoscaler ? helm_release.cluster_autoscaler[0].name : null
}

output "helm_release_version" {
  description = "Version of the Cluster Autoscaler Helm release"
  value       = var.enable_autoscaler ? helm_release.cluster_autoscaler[0].version : null
}
