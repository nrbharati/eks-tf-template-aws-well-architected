# Add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  addon_version = var.vpc_cni_version
  resolve_conflicts_on_update = "OVERWRITE"
#   depends_on = [ 
#     aws_eks_node_group.this 
#     ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"
  addon_version = var.coredns_version
  resolve_conflicts_on_update = "OVERWRITE"
#   depends_on = [ 
#     aws_eks_node_group.this 
#     ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
  addon_version = var.kube_proxy_version
  resolve_conflicts_on_update = "OVERWRITE"
  # depends_on = [ 
  #   aws_eks_node_group.this 
  #   ]
}

resource "aws_eks_addon" "ebs_csi" {
  count = var.enable_ebs_driver ? 1 : 0
  
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.ebs_csi_driver_chart_version
  resolve_conflicts_on_update = "OVERWRITE"
}

# metrics-server/main.tf

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_helm_chart_version

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"
      ]
    })
  ]
}

resource "aws_iam_policy" "ebs_csi" {
  name        = "${var.cluster_name}-ebs-csi-policy"
  description = "EBS CSI driver policy"
  policy      = data.aws_iam_policy_document.ebs_csi.json
}

data "aws_iam_policy_document" "ebs_csi" {
  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:CreateVolume",
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ebs_csi_controller" {
  name = "${var.cluster_name}-ebs-csi-controller"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.openid_connect_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_controller.name
  policy_arn = aws_iam_policy.ebs_csi.arn
}

resource "kubernetes_service_account" "ebs_csi_controller" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_controller.arn
    }
  }
}