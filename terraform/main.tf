# Main Terraform configuration file for AWS EKS

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
        "karpenter.sh/capacity-type" = "on-demand"
        "node.kubernetes.io/instance-type" = "on-demand"
        "karpenter.sh/do-not-evict" = "true"
      } : {})
    })
  }
  
  # Dynamically add autoscaling configuration when EKS autoscaler is enabled
  node_groups_with_autoscaling = {
    for k, v in local.node_groups_with_karpenter : k => merge(v, {
      scaling_config = merge(v.scaling_config, var.enable_eks_autoscaler ? {
        min_size = v.scaling_config.min_size
        max_size = max(v.scaling_config.max_size, v.scaling_config.desired_size + 2)  # Ensure max_size allows scaling
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
  source = "./modules/security"

  vpc_id      = var.vpc_id
  cluster_name = var.cluster_name
  tags = var.tags
}

# Create EKS cluster using existing VPC and subnets
module "eks" {
  source = "./modules/eks"

  cluster_name    = local.cluster_name_with_suffix
  cluster_version = var.cluster_version
  aws_region      = var.aws_region
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids
  node_groups     = local.node_groups_with_autoscaling
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
  source = "./modules/monitoring"
  
  cluster_name = local.cluster_name_with_suffix
  enable_monitoring = var.enable_monitoring

  grafana_admin_user = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password

  domain_name = var.domain_name
  grafana_ingress_class = var.grafana_ingress_class
  grafana_hostname = var.grafana_hostname

  # Monitoring Ingress Configuration
  alb_group_name = var.alb_group_name
  alb_subnets = var.alb_subnets
  alb_certificate_arn = var.alb_certificate_arn

  prometheus_helm_chart_version = var.prometheus_helm_chart_version
  fluentbit_helm_chart_version = var.fluentbit_helm_chart_version

  aws_region = var.aws_region
  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url

  tags = var.tags

  depends_on = [
    module.eks,
    module.addons
  ]
}

module "addons" {
  source = "./modules/addons"
  
  cluster_name = local.cluster_name_with_suffix
  aws_region      = var.aws_region
  vpc_id = var.vpc_id

  vpc_cni_version = var.vpc_cni_version
  coredns_version = var.coredns_version
  kube_proxy_version = var.kube_proxy_version
  
  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url

  domain_name = var.domain_name
  alb_controller_helm_chart_version = var.alb_controller_helm_chart_version
  external_dns_chart_version = var.external_dns_chart_version
  enable_efs_driver = var.enable_efs_driver
  enable_ebs_driver = var.enable_ebs_driver

  depends_on = [module.eks]
}

module "rbac" {
  source = "./modules/rbac"

  cluster_name = module.eks.cluster_name
  sso_roles    = var.sso_roles
  tags = var.tags

  depends_on = [module.eks]
}

# Update Kubernetes module to use new Karpenter roles
module "kubernetes" {
  source = "./modules/kubernetes"
  
  cluster_name = local.cluster_name_with_suffix
  cluster_endpoint = module.eks.cluster_endpoint
  karpenter_node_role_arn = var.enable_karpenter ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name_with_suffix}-karpenter" : null
  karpenter_controller_role_arn = var.enable_karpenter ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name_with_suffix}-karpenter-controller" : null
  karpenter_instance_profile_name = var.enable_karpenter ? "${local.cluster_name_with_suffix}-karpenter" : null
  enable_karpenter = var.enable_karpenter
}

# New Karpenter module v0.37
module "karpenter" {
  count  = var.enable_karpenter ? 1 : 0
  source = "./modules/karpenter"

  cluster_name                    = local.cluster_name_with_suffix
  cluster_endpoint                = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  aws_region                      = var.aws_region
  vpc_id                          = var.vpc_id
  private_subnet_ids              = var.private_subnet_ids
  node_security_group_id          = module.security.node_security_group_id
  openid_connect_provider_arn     = module.eks.oidc_provider_arn
  openid_connect_provider_url     = module.eks.cluster_oidc_issuer_url

  # Karpenter Configuration
  karpenter_version               = "0.36.0"
  instance_types                  = var.karpenter_instance_types
  capacity_types                  = var.karpenter_capacity_types
  consolidation_enabled           = true
  ttl_seconds_after_empty         = 300
  ttl_seconds_until_expired       = 2592000

  # Resource Limits
  max_cpu                         = var.karpenter_limits.cpu
  max_memory                      = var.karpenter_limits.memory

  # Node Configuration
  node_labels = {
    "karpenter.sh/capacity-type" = "spot"
    "node.kubernetes.io/instance-type" = "spot"
  }

  # Monitoring
  enable_metrics_server           = true
  enable_cloudwatch_logs          = true
  enable_ssm_access               = true

  # CSI Drivers
  enable_ebs_csi_driver           = false
  enable_efs_csi_driver           = var.enable_efs_driver

  tags = var.tags

  depends_on = [module.eks, module.addons]
}

# Backup module
module "backup" {
  source = "./modules/backup"

  cluster_name = local.cluster_name_with_suffix
  aws_region   = var.aws_region

  # Backup configuration
  enable_etcd_backup = var.backup_config.enable_etcd_backup
  backup_retention_days = var.backup_config.backup_retention_days
  backup_schedule = var.backup_config.backup_schedule

  tags = var.tags

  depends_on = [module.eks]
}

# EKS Auto Mode Module - Cluster Autoscaler
module "eks_autoscaler" {
  count  = var.enable_eks_autoscaler ? 1 : 0
  source = "./modules/eks-autoscaler"

  enable_autoscaler = var.enable_eks_autoscaler
  cluster_name      = local.cluster_name_with_suffix
  aws_region        = var.aws_region

  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url

  # Scaling configuration
  scale_down_enabled = var.autoscaler_config.scale_down_enabled
  scale_down_delay_after_add = var.autoscaler_config.scale_down_delay_after_add
  scale_down_unneeded = var.autoscaler_config.scale_down_unneeded
  max_node_provision_time = var.autoscaler_config.max_node_provision_time
  scan_interval = var.autoscaler_config.scan_interval
  scale_down_utilization_threshold = var.autoscaler_config.scale_down_utilization_threshold
  skip_nodes_with_local_storage = var.autoscaler_config.skip_nodes_with_local_storage
  skip_nodes_with_system_pods = var.autoscaler_config.skip_nodes_with_system_pods
  expander = var.autoscaler_config.expander
  balance_similar_node_groups = var.autoscaler_config.balance_similar_node_groups
  max_total_unready_percentage = var.autoscaler_config.max_total_unready_percentage
  ok_total_unready_count = var.autoscaler_config.ok_total_unready_count

  tags = var.tags

  depends_on = [module.eks, module.addons, module.kubernetes]
}

module "vpc" {
  source = "./modules/vpc"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  cluster_name       = local.cluster_name_with_suffix
  environment        = var.environment
}