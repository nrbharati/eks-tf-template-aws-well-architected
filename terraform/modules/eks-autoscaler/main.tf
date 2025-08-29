# EKS Auto Mode Module - Cluster Autoscaler for automatic node scaling

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Create IAM role for Cluster Autoscaler
resource "aws_iam_role" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  name = "${var.cluster_name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.openid_connect_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Create IAM policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  name        = "${var.cluster_name}-cluster-autoscaler-policy"
  description = "Policy for Cluster Autoscaler to manage EKS node groups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  role       = aws_iam_role.cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}

# Create Kubernetes service account
resource "kubernetes_service_account" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler[0].arn
    }
  }
}

# Create ClusterRole for Cluster Autoscaler
resource "kubernetes_cluster_role" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  metadata {
    name = "cluster-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs      = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources  = ["leases"]
    verbs      = ["get", "update"]
  }
}

# Create ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  metadata {
    name = "cluster-autoscaler"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

# Create Role for Cluster Autoscaler
resource "kubernetes_role" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs      = ["delete", "get", "update", "watch"]
  }
}

# Create RoleBinding
resource "kubernetes_role_binding" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

# Deploy Cluster Autoscaler using Helm
resource "helm_release" "cluster_autoscaler" {
  count = var.enable_autoscaler ? 1 : 0
  
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false
  version          = var.cluster_autoscaler_version

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler[0].arn
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.scale-down-enabled"
    value = var.scale_down_enabled
  }

  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = var.scale_down_delay_after_add
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = var.scale_down_unneeded
  }

  set {
    name  = "extraArgs.max-node-provision-time"
    value = var.max_node_provision_time
  }

  set {
    name  = "extraArgs.scan-interval"
    value = var.scan_interval
  }

  set {
    name  = "extraArgs.scale-down-utilization-threshold"
    value = var.scale_down_utilization_threshold
  }

  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = var.skip_nodes_with_local_storage
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = var.skip_nodes_with_system_pods
  }

  set {
    name  = "extraArgs.expander"
    value = var.expander
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = var.balance_similar_node_groups
  }

  set {
    name  = "extraArgs.max-total-unready-percentage"
    value = var.max_total_unready_percentage
  }

  set {
    name  = "extraArgs.ok-total-unready-count"
    value = var.ok_total_unready_count
  }

  depends_on = [
    kubernetes_service_account.cluster_autoscaler[0],
    kubernetes_cluster_role.cluster_autoscaler[0],
    kubernetes_cluster_role_binding.cluster_autoscaler[0],
    kubernetes_role.cluster_autoscaler[0],
    kubernetes_role_binding.cluster_autoscaler[0]
  ]
}
