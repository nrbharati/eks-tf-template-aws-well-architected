# Terraform variables configuration

aws_region = "us-east-1"
environment = "non-prod"

# VPC Configuration
vpc_id = "vpc-XXXXXXXXX" # Replace with your existing VPC ID
private_subnet_ids = ["subnet-XXXXXXXXX","subnet-XXXXXXXXX","subnet-XXXXXXXXX"] # Replace with your existing private subnet IDs
public_subnet_ids = ["subnet-XXXXXXXXX","subnet-XXXXXXXXX","subnet-XXXXXXXXX"] # Replace with your existing public subnet IDs

# EKS Cluster Configuration
cluster_name = "eks-frontend-cluster"
cluster_version = "1.33"
ssh_key_name = "eks-web-key"  # SSH key for non-prod nodes

# SSO Roles for EKS Access (using standard AWS SSO role patterns)
# These are common AWS SSO role names that you can customize based on your organization
sso_roles = {
  global_admin   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_XXXXXXXXX"
  administrator  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PowerUserAccess_XXXXXXXXX"
  developer      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_DeveloperAccess_XXXXXXXXX"
  viewer         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_XXXXXXXXX"
}

# Enable/Disable Karpenter
enable_karpenter = false

# Enable/Disable EKS Cluster Autoscaler
enable_eks_autoscaler = true

# Storage Configuration
enable_efs_driver = true
enable_ebs_driver = false

# Add ons - Updated for EKS 1.33 compatibility
vpc_cni_version = "v1.20.1-eksbuild.1"
coredns_version = "v1.12.2-eksbuild.4"
kube_proxy_version = "v1.33.3-eksbuild.4"
external_dns_chart_version = "1.16.1"
alb_controller_helm_chart_version = "1.13.2"
fluentbit_helm_chart_version = "0.46.6"

# Node Groups
node_groups = {
  main = {
    instance_types = ["t3.large", "t3.xlarge"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3
      min_size     = 2
      max_size     = 6
    }
    labels = {
      "role" = "general"
      "environment" = "non-prod"
    }
    taints = []
  }
  
  compute = {
    instance_types = ["t3.xlarge", "c5.large", "c5.xlarge"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 0
      min_size     = 0
      max_size     = 4
    }
    labels = {
      "role" = "compute"
      "environment" = "non-prod"
    }
    taints = []
  }
  
  memory = {
    instance_types = ["t3.xlarge", "r5.large"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 0
      min_size     = 0
      max_size     = 3
    }
    labels = {
      "role" = "memory"
      "environment" = "non-prod"
    }
    taints = []
  }
}
# AMI ID is now automatically selected using data source for Amazon Linux 2023
# ami_id = "ami-XXXXXXXXX"  # Replace with your desired AMI ID

# Karpenter Configuration
karpenter_version = "0.36.0"
karpenter_instance_types = ["t3.medium", "t3.large", "t3.xlarge"]

karpenter_limits = {
  cpu    = "100"
  memory = "100Gi"
}

# Monitoring
# enable_prometheus = true
# enable_grafana = true
enable_monitoring = true
grafana_admin_password = "eksadmin@dev0ps"
grafana_admin_user = "admin"
grafana_hostname = "grafana.frontend.nonprod-aws.example.com"
grafana_ingress_class = "alb"

# ALB Configuration
alb_group_name = "eks-frontend-cluster-alb-group"
alb_subnets = "subnet-XXXXXXXXX,subnet-XXXXXXXXX,subnet-XXXXXXXXX"
alb_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

prometheus_helm_chart_version = "75.0.0"


metrics_server_helm_chart_version = "3.12.2"
vpa_helm_chart_version = "4.7.0"

# External DNS Configuration
domain_name = "nonprod-aws.example.com"


# Tags
default_tags = {
  Environment = "non-prod"
  ManagedBy   = "terraform"
  Project     = "eks-framework"
}


tags = {
  Owner = "DevOps"
  Group = "Nikhil Bharati"
}

# Horizontal Pod Autoscaling
# hpa_min_replicas = 1
# hpa_max_replicas = 10
# hpa_cpu_target_utilization = 80
# hpa_memory_target_utilization = 80

# Vertical Pod Autoscaling
# vpa_min_cpu = "100m"
# vpa_min_memory = "128Mi"
# vpa_max_cpu = "1000m"
# vpa_max_memory = "1Gi"

# Enhanced Cluster Configuration
cluster_config = {
  endpoint_private_access = true
  endpoint_public_access  = true
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  encryption_config = {
    resources = ["secrets"]
    kms_key_arn = null  # Replace with your KMS key ARN if available
  }
}

# Enhanced Karpenter Configuration
karpenter_config = {
  instance_types = ["t3.medium", "t3.large", "t3.xlarge"]
  capacity_types = ["on-demand", "spot"]
  consolidation = {
    enabled = true
  }
  limits = {
    cpu    = "100"
    memory = "100Gi"
  }
}

# Enhanced Monitoring Configuration
monitoring_config = {
  enable_container_insights = true
  log_retention_days = 30
  metrics_retention_days = 15
}

# Pod Security Configuration
pod_security_config = {
  enable_psp = true
  enable_network_policy = true
  enable_pod_security_standards = true
}

# Backup Configuration
backup_config = {
  enable_etcd_backup = true
  backup_retention_days = 7
  backup_schedule = "cron(0 5 ? * * *)"  # Daily at 5 AM UTC
}

# EKS Autoscaler Configuration
autoscaler_config = {
  scale_down_enabled = true
  scale_down_delay_after_add = "10m"
  scale_down_unneeded = "10m"
  max_node_provision_time = "15m"
  scan_interval = "10s"
  scale_down_utilization_threshold = "0.5"
  skip_nodes_with_local_storage = true
  skip_nodes_with_system_pods = true
  expander = "least-waste"
  balance_similar_node_groups = true
  max_total_unready_percentage = "45"
  ok_total_unready_count = "3"
}

default_instance_types = ["t3.medium", "t3.large", "m5.large"]

external_dns_helm_chart_version = "1.16.1"
kube_prometheus_stack_helm_chart_version = "75.0.0"