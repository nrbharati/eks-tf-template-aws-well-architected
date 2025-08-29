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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Create IAM role for Karpenter nodes
resource "aws_iam_role" "karpenter" {
  name = "${var.cluster_name}-karpenter"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach required policies to the Karpenter role
resource "aws_iam_role_policy_attachment" "karpenter_worker" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_cni" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_registry" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create custom EC2 policy for Karpenter
resource "aws_iam_policy" "karpenter_ec2" {
  name        = "${var.cluster_name}-karpenter-ec2-policy"
  description = "Policy with required EC2 permissions for Karpenter"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:RequestSpotInstances",
          "ec2:CancelSpotInstanceRequests",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:DescribeKeyPairs",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:ImportKeyPair",
          "ec2:DescribePlacementGroups",
          "ec2:CreatePlacementGroup",
          "ec2:DeletePlacementGroup",
          "ec2:DescribeFleets",
          "ec2:CreateFleet",
          "ec2:DeleteFleets",
          "ec2:DescribeCapacityReservations",
          "ec2:CreateCapacityReservation",
          "ec2:DeleteCapacityReservation",
          "ec2:DescribeReservedInstances",
          "ec2:PurchaseReservedInstancesOffering",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:DescribeHosts",
          "ec2:AllocateHosts",
          "ec2:ReleaseHosts",
          "ec2:DescribeScheduledInstances",
          "ec2:PurchaseScheduledInstances",
          "ec2:CancelScheduledInstances",
          "ec2:DescribeElasticGpus",
          "ec2:AttachElasticGpu",
          "ec2:DetachElasticGpu",
          "ec2:DescribeFpgaImages",
          "ec2:DescribeBundleTasks",
          "ec2:BundleInstance",
          "ec2:CancelBundleTask",
          "ec2:DescribeExportTasks",
          "ec2:CreateExportTask",
          "ec2:CancelExportTask",
          "ec2:DescribeImportImageTasks",
          "ec2:ImportImage",
          "ec2:CancelImportTask",
          "ec2:DescribeImportSnapshotTasks",
          "ec2:ImportSnapshot",
          "ec2:CancelImportTask",
          "ec2:DescribeConversionTasks",
          "ec2:ImportInstance",
          "ec2:CancelConversionTask",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeVpcClassicLinkDnsSupport",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:AcceptVpcPeeringConnection",
          "ec2:RejectVpcPeeringConnection",
          "ec2:CreateVpcPeeringConnection",
          "ec2:DeleteVpcPeeringConnection",
          "ec2:ModifyVpcPeeringConnectionOptions",
          "ec2:DescribeVpcEndpointConnections",
          "ec2:DescribeVpcEndpoints",
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpcEndpoints",
          "ec2:ModifyVpcEndpoint",
          "ec2:DescribeVpcEndpointServiceConfigurations",
          "ec2:CreateVpcEndpointServiceConfiguration",
          "ec2:DeleteVpcEndpointServiceConfigurations",
          "ec2:ModifyVpcEndpointServiceConfiguration",
          "ec2:DescribeVpcEndpointServices",
          "ec2:AcceptVpcEndpointConnections",
          "ec2:RejectVpcEndpointConnections",
          "ec2:DescribeVpcEndpointConnectionNotifications",
          "ec2:CreateVpcEndpointConnectionNotification",
          "ec2:DeleteVpcEndpointConnectionNotifications",
          "ec2:DescribeVpcEndpointServicePermissions",
          "ec2:ModifyVpcEndpointServicePermissions",
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/aws/service/eks/optimized-ami/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetInstanceProfile",
          "iam:PassRole",
          "iam:AddRoleToInstanceProfile"
        ]
        Resource = [
          "arn:aws:iam::*:role/*",
          "arn:aws:iam::*:instance-profile/*"
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "karpenter_ec2" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter_ec2.arn
}

# Create instance profile for Karpenter nodes
resource "aws_iam_instance_profile" "karpenter" {
  name = "${var.cluster_name}-karpenter-instance-profile"
  role = aws_iam_role.karpenter.name
}

# Create IAM role for Karpenter controller
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

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
            "${replace(var.openid_connect_provider_url, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach the same EC2 policy to the controller role
resource "aws_iam_role_policy_attachment" "karpenter_controller_ec2" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_ec2.arn
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  create_duration = "30s"
}

# Install Karpenter v0.16.3
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  version          = "0.16.3"
  namespace        = "karpenter"
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "controller.env[0].name"
    value = "CLUSTER_NAME"
  }

  set {
    name  = "controller.env[0].value"
    value = var.cluster_name
  }

  set {
    name  = "controller.env[1].name"
    value = "CLUSTER_ENDPOINT"
  }

  set {
    name  = "controller.env[1].value"
    value = var.cluster_endpoint
  }

  # Instance profile is configured in AWSNodeTemplate, not in Helm values for v0.16.3
set {
  name = "aws.defaultInstanceProfile"
  value = aws_iam_instance_profile.karpenter.name
}
  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  depends_on = [time_sleep.wait_for_cert_manager]
}

# Wait for Karpenter to be ready
resource "time_sleep" "wait_for_karpenter" {
  create_duration = "30s"
  
  depends_on = [helm_release.karpenter]
}

# Create EC2NodeClass for Karpenter v0.16.3
resource "null_resource" "karpenter_ec2nodeclass" {
  triggers = {
    cluster_name = var.cluster_name
    instance_profile = aws_iam_instance_profile.karpenter.name
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - << 'EOF'
      apiVersion: karpenter.k8s.aws/v1alpha1
      kind: AWSNodeTemplate
      metadata:
        name: default
      spec:
        amiFamily: AL2
        # No userData - let EKS-optimized AMI handle bootstrap automatically
        instanceProfile: ${aws_iam_instance_profile.karpenter.name}
        securityGroupSelector:
          kubernetes.io/cluster/${var.cluster_name}: owned
        subnetSelector:
          kubernetes.io/cluster/${var.cluster_name}: shared
      EOF
    EOT
  }

  depends_on = [time_sleep.wait_for_karpenter]
}

# Create Provisioner for Karpenter v0.16.3
resource "null_resource" "karpenter_provisioner" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - << 'EOF'
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  limits:
    resources:
      cpu: "1000"
      memory: "1000Gi"
  requirements:
  - key: karpenter.k8s.aws/instance-category
    operator: In
    values: ["c", "m", "r"]
  - key: karpenter.k8s.aws/instance-generation
    operator: Gt
    values: ["2"]
  - key: kubernetes.io/arch
    operator: In
    values: ["amd64"]
  - key: kubernetes.io/os
    operator: In
    values: ["linux"]
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["on-demand", "spot"]
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
EOF
    EOT
  }

  depends_on = [null_resource.karpenter_ec2nodeclass]
} 