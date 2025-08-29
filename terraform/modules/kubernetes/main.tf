# Kubernetes Module for EKS cluster resources

locals {
  cluster_name = var.cluster_name
}

# Create instance profile for Karpenter nodes
resource "aws_iam_instance_profile" "karpenter" {
  count = var.enable_karpenter ? 1 : 0
  name = "${local.cluster_name}-karpenter"
  role = replace(var.karpenter_node_role_arn, "arn:aws:iam::ACCOUNT_ID:role/", "")
}

# Cert Manager Helm Release
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.3"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.servicemonitor.enabled"
    value = "true"
  }
}

# Wait for Cert Manager to stabilize
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "30s"
} 