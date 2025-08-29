resource "aws_iam_role" "efs_csi" {
  count = var.enable_efs_driver ? 1 : 0
  
  name = "${var.cluster_name}-efs-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.openid_connect_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_attach" {
  count = var.enable_efs_driver ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi[0].name
}

resource "kubernetes_service_account" "efs_csi" {
  count = var.enable_efs_driver ? 1 : 0
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.efs_csi[0].arn
    }
  }
}

resource "helm_release" "efs_csi_driver" {
  count = var.enable_efs_driver ? 1 : 0
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = var.efs_csi_driver_chart_version

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.efs_csi[0].metadata[0].name
        }
      }
    })
  ]

  depends_on = [
    kubernetes_service_account.efs_csi,
    aws_iam_role_policy_attachment.efs_csi_attach
  ]
}
