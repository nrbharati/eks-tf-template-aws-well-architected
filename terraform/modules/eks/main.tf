# EKS Module

locals {
  cluster_name = var.cluster_name
}

# Add AWS caller identity data source
data "aws_caller_identity" "current" {}

# Data source for Amazon Linux EKS-optimized AMI
data "aws_ami" "eks_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [
      "amazon-eks-node-${var.cluster_version}-*",
      "amazon-eks-node-1.3*-*"  # Fallback to any 1.3x version
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = toset([var.cluster_security_group_id])
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Add access configuration
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = var.tags

  # Add timeouts to prevent hanging operations
  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }
}

# Add EKS Access Entry for admin user
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/YOUR_USER_NAME"
  type          = "STANDARD"

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name}-admin-access"
    }
  )
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin.principal_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

resource "aws_iam_role" "node" {
  name = "${local.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Use standard EKS node group without custom launch template
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  # Use AL2023 AMI directly
  ami_type = "AL2023_x86_64_STANDARD"  # Use Amazon Linux 2023 Standard

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    min_size     = each.value.scaling_config.min_size
    max_size     = each.value.scaling_config.max_size
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = each.value.labels

  # Add SSH key for debugging (if provided)
  dynamic "remote_access" {
    for_each = var.ssh_key_name != null ? [1] : []
    content {
      ec2_ssh_key = var.ssh_key_name
      source_security_group_ids = [var.node_security_group_id]
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.this,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name}-${each.key}"
    }
  )

  # Add timeouts to prevent hanging operations
  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }
}

# OIDC Provider for service accounts
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# EKS automatically creates the aws-auth ConfigMap, so we don't need to manage it manually
# resource "kubernetes_config_map_v1" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
# 
#   data = {
#     mapRoles = yamlencode([
#       {
#         rolearn  = aws_iam_role.node.arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       },
#       {
#         rolearn  = var.karpenter_node_role_arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = [
#           "system:bootstrappers",
#           "system:nodes"
#         ]
#       }
#     ]
#     mapUsers = yamlencode([
#       {
#         userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/YOUR_USER_NAME"
#         username = "YOUR_USER_NAME"
#         groups   = [
#           "system:masters"
#         ]
#       }
#     ])
#   }
# 
#   depends_on = [
#     aws_eks_cluster.this,
#     aws_iam_role.node,
#     aws_eks_access_entry.admin,
#     aws_eks_access_policy_association.admin
#   ]
# }


