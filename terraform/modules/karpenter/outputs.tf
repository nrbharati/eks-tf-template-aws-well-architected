output "karpenter_namespace" {
  description = "Name of the Karpenter namespace"
  value       = "karpenter"
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role for Karpenter nodes"
  value       = aws_iam_role.karpenter.arn
}

output "karpenter_node_role_name" {
  description = "Name of the IAM role for Karpenter nodes"
  value       = aws_iam_role.karpenter.name
}

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter controller"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_controller_role_name" {
  description = "Name of the IAM role for Karpenter controller"
  value       = aws_iam_role.karpenter_controller.name
}

output "karpenter_instance_profile_arn" {
  description = "ARN of the IAM instance profile for Karpenter nodes"
  value       = aws_iam_instance_profile.karpenter.arn
}

output "karpenter_instance_profile_name" {
  description = "Name of the IAM instance profile for Karpenter nodes"
  value       = aws_iam_instance_profile.karpenter.name
}

output "karpenter_ec2_policy_arn" {
  description = "ARN of the EC2 policy for Karpenter"
  value       = aws_iam_policy.karpenter_ec2.arn
}

output "karpenter_ec2_policy_name" {
  description = "Name of the EC2 policy for Karpenter"
  value       = aws_iam_policy.karpenter_ec2.name
}

output "cert_manager_namespace" {
  description = "Name of the cert-manager namespace"
  value       = "cert-manager"
}

output "metrics_server_namespace" {
  description = "Name of the metrics-server namespace"
  value       = "kube-system"
}

output "ebs_csi_driver_namespace" {
  description = "Name of the EBS CSI driver namespace"
  value       = "kube-system"
}

output "efs_csi_driver_namespace" {
  description = "Name of the EFS CSI driver namespace"
  value       = "kube-system"
}

output "aws_node_termination_handler_namespace" {
  description = "Name of the AWS Node Termination Handler namespace"
  value       = "kube-system"
} 