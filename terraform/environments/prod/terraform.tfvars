# Production Environment Terraform Variables
# Update these values according to your production AWS account and infrastructure

# AWS Configuration
aws_region  = "us-east-1" # Change to your production region
environment = "production"

# VPC Configuration
vpc_id             = "vpc-XXXXXXXXX"                                                              # Replace with your production VPC ID
private_subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX", "subnet-XXXXXXXXX"] # Replace with your production private subnet IDs
public_subnet_ids  = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX", "subnet-XXXXXXXXX"] # Replace with your production public subnet IDs

# EKS Configuration
cluster_name    = "eks-prod-frontend-cluster"
cluster_version = "1.33"
ssh_key_name    = "eks-web-asg-key"

# Autoscaling Configuration
enable_karpenter      = false
enable_eks_autoscaler = true

# Cluster Configuration
cluster_config = {
  endpoint_private_access = true
  endpoint_public_access  = true # Production should be private only
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  encryption_config = {
    resources   = ["secrets"]
    kms_key_arn = null # Replace with your KMS key ARN if available
  }
}

# Storage Configuration
enable_efs_driver = true
enable_ebs_driver = false

# Add-ons Versions
vpc_cni_version                   = "v1.20.1-eksbuild.1"
coredns_version                   = "v1.12.2-eksbuild.4"
kube_proxy_version                = "v1.33.3-eksbuild.4"
external_dns_chart_version        = "1.16.1"
alb_controller_helm_chart_version = "1.13.2"
fluentbit_helm_chart_version      = "0.46.6"

# Production Node Groups - More robust configuration for production
node_groups = {
  main = {
    instance_types = ["t3.large", "t3.xlarge", "c5.large", "c5.xlarge"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3
      min_size     = 3
      max_size     = 8
    }
    labels = {
      "role"        = "general"
      "environment" = "production"
    }
    taints = []
  }

  compute = {
    instance_types = ["c5.2xlarge", "c5.4xlarge", "c5n.2xlarge"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 0
      min_size     = 0
      max_size     = 6
    }
    labels = {
      "role"        = "compute"
      "environment" = "production"
    }
    taints = []
  }

  memory = {
    instance_types = ["r5.large", "r5.xlarge", "r5.2xlarge"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 0
      min_size     = 0
      max_size     = 4
    }
    labels = {
      "role"        = "memory"
      "environment" = "production"
    }
    taints = []
  }
}

# Karpenter Configuration (if enabled)
karpenter_version        = "0.36.0"
karpenter_instance_types = ["t3.large", "t3.xlarge", "c5.large", "c5.xlarge", "m5.large", "m5.xlarge"]
karpenter_capacity_types = ["on-demand"] # Production typically uses on-demand only
karpenter_limits = {
  cpu    = "200"
  memory = "200Gi"
}

# Monitoring Configuration
enable_monitoring      = true   # Now enabled for full deployment
grafana_admin_password = "Admin@123" # Change this to a secure password
grafana_admin_user     = "admin"
grafana_hostname       = "monitoring.prod-aws.example.com" # Monitoring hostname for production
grafana_ingress_class  = "alb"

# Monitoring Versions
prometheus_helm_chart_version     = "75.0.0"
metrics_server_helm_chart_version = "3.12.2"
vpa_helm_chart_version            = "4.7.0"

# Production Domain
domain_name = "prod-aws.example.com" # Update with your production domain

# Production Monitoring Ingress Configuration
# Note: These values need to be updated with actual production values
alb_group_name = "eks-prod-frontend-cluster-int-internal" # Internal ALB group for production
alb_subnets = "subnet-XXXXXXXXX,subnet-XXXXXXXXX,subnet-XXXXXXXXX"     # Internal subnets for production
alb_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"  # TODO: Update with production ACM certificate ARN

# SSO Roles for EKS Access (using standard AWS SSO role patterns)
# These are common AWS SSO role names that you can customize based on your organization
  sso_roles = {
    global_admin   = "arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_XXXXXXXXX"
    administrator  = "arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PowerUserAccess_XXXXXXXXX"
    developer      = "arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_DeveloperAccess_XXXXXXXXX"
    viewer         = "arn:aws:iam::ACCOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_XXXXXXXXX"
  }

# Production Tags
default_tags = {
  Environment = "production"
  ManagedBy   = "terraform"
  Project     = "eks-framework"
  CostCenter  = "production"
  Compliance  = "high"
}

tags = {
  Owner      = "DevOps"
  Group      = "Production Team"
  Backup     = "daily"
  Monitoring = "24x7"
}

# Backup Configuration
enable_backup         = true
backup_retention_days = 30
backup_schedule       = "cron(0 2 * * ? *)" # Daily at 2 AM

# Enhanced Monitoring Configuration
monitoring_config = {
  enable_container_insights = true
  log_retention_days        = 30
  metrics_retention_days    = 15
}

# Pod Security Configuration
pod_security_config = {
  enable_psp                    = true
  enable_network_policy         = true
  enable_pod_security_standards = true
}
