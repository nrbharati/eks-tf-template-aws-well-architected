# Production EKS Cluster Configuration
# This file extends the base configuration for production environment

# Generate random suffix for cluster name to avoid conflicts
resource "random_string" "cluster_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  cluster_name_with_suffix = "${var.cluster_name}-${random_string.cluster_suffix.result}"

  # Dynamically add Karpenter labels to node groups when enabled
  node_groups_with_karpenter = {
    for k, v in var.node_groups : k => merge(v, {
      labels = merge(v.labels, var.enable_karpenter ? {
        "karpenter.sh/capacity-type"       = "on-demand"
        "node.kubernetes.io/instance-type" = "on-demand"
        "karpenter.sh/do-not-evict"        = "true"
      } : {})
    })
  }

  # Dynamically add autoscaling configuration when EKS autoscaler is enabled
  node_groups_with_autoscaling = {
    for k, v in local.node_groups_with_karpenter : k => merge(v, {
      scaling_config = merge(v.scaling_config, var.enable_eks_autoscaler ? {
        min_size     = v.scaling_config.min_size
        max_size     = max(v.scaling_config.max_size, v.scaling_config.desired_size + 2)
        desired_size = v.scaling_config.desired_size
      } : v.scaling_config)
    })
  }
}

# Data sources to fetch existing VPC and subnets
data "aws_caller_identity" "current" {}

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.private_subnet_ids
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = var.public_subnet_ids
  }
}

# Create security groups first
module "security" {
  source = "../../modules/security"

  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name
  tags         = var.tags
}

# Create EKS cluster using existing VPC and subnets
module "eks" {
  source = "../../modules/eks"

  cluster_name              = local.cluster_name_with_suffix
  cluster_version           = var.cluster_version
  aws_region                = var.aws_region
  vpc_id                    = var.vpc_id
  subnet_ids                = var.private_subnet_ids
  node_groups               = local.node_groups_with_autoscaling
  cluster_security_group_id = module.security.cluster_security_group_id
  node_security_group_id    = module.security.node_security_group_id
  endpoint_private_access   = var.cluster_config.endpoint_private_access
  endpoint_public_access    = var.cluster_config.endpoint_public_access
  enabled_cluster_log_types = var.cluster_config.enabled_cluster_log_types
  karpenter_node_role_arn   = var.enable_karpenter ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name_with_suffix}-karpenter" : null
  ssh_key_name              = var.ssh_key_name
  tags                      = var.tags
}

# Enhanced monitoring module
module "monitoring" {
  source = "../../modules/monitoring"

  cluster_name                  = local.cluster_name_with_suffix
  enable_monitoring             = var.enable_monitoring
  grafana_admin_password        = var.grafana_admin_password
  grafana_admin_user            = var.grafana_admin_user
  grafana_ingress_class         = var.grafana_ingress_class
  grafana_hostname              = var.grafana_hostname
  prometheus_helm_chart_version = var.prometheus_helm_chart_version
  fluentbit_helm_chart_version  = var.fluentbit_helm_chart_version
  domain_name                   = var.domain_name
  
  # Monitoring Ingress Configuration
  alb_group_name                = var.alb_group_name
  alb_subnets                   = var.alb_subnets
  alb_certificate_arn           = var.alb_certificate_arn
  
  openid_connect_provider_arn   = module.eks.oidc_provider_arn
  openid_connect_provider_url   = module.eks.cluster_oidc_issuer_url
  aws_region                    = var.aws_region
  tags                          = var.tags

  depends_on = [module.eks, module.addons]
}

# Kubernetes providers configuration
module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name                    = local.cluster_name_with_suffix
  cluster_endpoint                = module.eks.cluster_endpoint
  enable_karpenter                = var.enable_karpenter
  karpenter_node_role_arn         = var.enable_karpenter ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name_with_suffix}-karpenter-node" : null
  karpenter_controller_role_arn   = var.enable_karpenter ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name_with_suffix}-karpenter-controller" : null
  karpenter_instance_profile_name = var.enable_karpenter ? "${local.cluster_name_with_suffix}-karpenter-profile" : null

  depends_on = [module.eks, module.monitoring]
}

# Add-ons module
module "addons" {
  source = "../../modules/addons"

  cluster_name = local.cluster_name_with_suffix
  aws_region   = var.aws_region
  vpc_id       = var.vpc_id

  vpc_cni_version    = var.vpc_cni_version
  coredns_version    = var.coredns_version
  kube_proxy_version = var.kube_proxy_version

  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url

  domain_name                       = var.domain_name
  alb_controller_helm_chart_version = var.alb_controller_helm_chart_version
  external_dns_chart_version        = var.external_dns_chart_version
  enable_efs_driver                 = var.enable_efs_driver
  enable_ebs_driver                 = var.enable_ebs_driver

  depends_on = [module.eks]
}

# Karpenter module (if enabled)
module "karpenter" {
  count  = var.enable_karpenter ? 1 : 0
  source = "../../modules/karpenter"

  cluster_name                       = local.cluster_name_with_suffix
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  aws_region                         = var.aws_region
  vpc_id                             = var.vpc_id
  private_subnet_ids                 = var.private_subnet_ids
  node_security_group_id             = module.security.node_security_group_id
  openid_connect_provider_arn        = module.eks.oidc_provider_arn
  openid_connect_provider_url        = module.eks.cluster_oidc_issuer_url

  karpenter_version = var.karpenter_version
  instance_types    = var.karpenter_instance_types
  capacity_types    = var.karpenter_capacity_types
  tags              = var.tags

  depends_on = [module.eks, module.addons]
}

# EKS Autoscaler module (if enabled)
module "eks_autoscaler" {
  count  = var.enable_eks_autoscaler ? 1 : 0
  source = "../../modules/eks-autoscaler"

  cluster_name                = local.cluster_name_with_suffix
  aws_region                  = var.aws_region
  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url

  depends_on = [module.eks, module.addons]
}

# RBAC module
module "rbac" {
  source = "../../modules/rbac"

  cluster_name = local.cluster_name_with_suffix
  sso_roles    = var.sso_roles
  tags         = var.tags

  depends_on = [module.eks, module.addons]
}
