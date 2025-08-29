# Variables for the EKS Terraform configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of existing private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI Helm chart"
  type        = string
  default     = "v1.19.2-eksbuild.5"
}

variable "coredns_version" {
  description = "Version of the CoreDNS Helm chart"
  type        = string
  default     = "v1.11.4-eksbuild.2"
}

variable "kube_proxy_version" {  
  description = "Version of the kube-proxy Helm chart"  
  type        = string  
  default     = "v1.30.9-eksbuild.3"
}

variable "enable_karpenter" {
  description = "Enable Karpenter for node autoscaling"
  type        = bool
  default     = true
}

variable "enable_eks_autoscaler" {
  description = "Enable EKS Cluster Autoscaler for node autoscaling"
  type        = bool
  default     = false
}

variable "node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })
    labels = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    main = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        min_size     = 2
        max_size     = 3
      }
      labels = {
        "role" = "general"
      }
      taints = []
    }
  }
}

variable "enable_prometheus" {
  description = "Enable Prometheus monitoring"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana dashboards"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "eks-framework"
  }
}

variable "ssh_key_name" {
  description = "SSH key pair name for EKS nodes"
  type        = string
  default     = null
}

variable "sso_roles" {
  description = "SSO role ARNs for EKS access"
  type = object({
    global_admin   = string
    administrator  = string
    developer      = string
    viewer         = string
  })
  default = {
    global_admin   = null
    administrator  = null
    developer      = null
    viewer         = null
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable monitoring resources"
  type        = bool
  default     = true 
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_hostname" {
  description = "Hostname for Grafana Ingress (must match internal DNS setup)"
  type        = string
}

variable "grafana_ingress_class" {
  description = "Ingress class name to use (e.g., alb)"
  type        = string
  default     = "alb"
}

variable "prometheus_helm_chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "45.7.1"
}

variable "metrics_server_helm_chart_version" {
  description = "Version of the metrics-server Helm chart"
  type        = string
  default     = "3.8.3"  
}

variable "vpa_helm_chart_version" {
  description = "Version of the vpa Helm chart"
  type        = string
  default     = "4.7.0"
}

variable "domain_name" {
  description = "Domain name for the cluster"
  type        = string
}

# Monitoring Ingress Configuration
variable "alb_group_name" {
  description = "ALB ingress group name for monitoring"
  type        = string
  default     = null
}

variable "alb_subnets" {
  description = "Comma-separated list of subnet IDs for ALB ingress"
  type        = string
  default     = null
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for ALB ingress HTTPS"
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for service accounts"
  type        = string
  default     = ""
}

variable "external_dns_chart_version" {
  description = "Version of the external-dns Helm chart"
  type        = string
  default     = "1.14.3" 
}

variable "alb_controller_helm_chart_version" {
  description = "Version of the ALB Controller Helm chart"
  type        = string  
  default     = "1.7.1"
}

variable "fluentbit_helm_chart_version" {
  description = "Version of the Fluent Bit Helm chart"
  type        = string
  default     = "0.46.6"
}

variable "ebs_csi_driver_chart_version" {
  description = "Version of the EBS CSI Driver addon"
  type        = string
  default     = "v1.47.0-eksbuild.1"
}

# AMI ID variable removed - now using data source for Amazon Linux 2023
# variable "ami_id" {
#   description = "ID of the AMI to use for the EKS nodes"
#   type        = string
# }

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "0.37.0"
}

variable "karpenter_instance_types" {
  description = "List of instance types for Karpenter nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge"]
}

variable "karpenter_cpu_requirements" {
  description = "CPU requirements for Karpenter nodes"
  type        = list(string)
  default     = ["1", "2", "4"]
}

variable "karpenter_memory_requirements" {
  description = "Memory requirements for Karpenter nodes"
  type        = list(string)
  default     = ["2Gi", "4Gi", "8Gi"]
}

variable "karpenter_capacity_types" {
  description = "Capacity types for Karpenter nodes"
  type        = list(string)
  default     = ["on-demand", "spot"]
}

variable "sso_admin_group" {
  description = "Name of the SSO group for cluster administrators"
  type        = string
  default     = "aws-sso-admin-group"
}

variable "sso_developer_group" {
  description = "Name of the SSO group for developers"
  type        = string
  default     = "aws-sso-developer-group"
}

variable "sso_viewer_group" {
  description = "Name of the SSO group for viewers"
  type        = string
  default     = "aws-sso-viewer-group"
}

variable "enable_efs_driver" {
  description = "Enable EFS CSI Driver"
  type        = bool
  default     = false
}

variable "enable_ebs_driver" {
  description = "Enable EBS CSI Driver"
  type        = bool
  default     = true
}

# variable "node_security_group_id" {
#   description = "List of security group IDs for the EKS nodes"
#   type = list(string)
# }

# Enhanced Cluster Configuration
variable "cluster_config" {
  description = "Enhanced EKS cluster configuration"
  type = object({
    endpoint_private_access = bool
    endpoint_public_access  = bool
    enabled_cluster_log_types = list(string)
    encryption_config = object({
      resources = list(string)
      kms_key_arn = string
    })
  })
  default = {
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
      kms_key_arn = null
    }
  }
}

# Enhanced Karpenter Configuration
variable "karpenter_config" {
  description = "Enhanced Karpenter configuration"
  type = object({
    instance_types = list(string)
    capacity_types = list(string)
    consolidation = object({
      enabled = bool
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    instance_types = [
      "t3.medium", "t3.large", "t3.xlarge",
      "m5.large", "m5.xlarge",
      "c5.large", "c5.xlarge"
    ]
    capacity_types = ["on-demand", "spot"]
    consolidation = {
      enabled = true
    }
    limits = {
      cpu    = "100"
      memory = "100Gi"
    }
  }
}

# Enhanced Monitoring Configuration
variable "monitoring_config" {
  description = "Enhanced monitoring configuration"
  type = object({
    enable_container_insights = bool
    log_retention_days = number
    metrics_retention_days = number
  })
  default = {
    enable_container_insights = true
    log_retention_days = 30
    metrics_retention_days = 15
  }
}

# Pod Security Configuration
variable "pod_security_config" {
  description = "Pod security configuration"
  type = object({
    enable_psp = bool
    enable_network_policy = bool
    enable_pod_security_standards = bool
  })
  default = {
    enable_psp = true
    enable_network_policy = true
    enable_pod_security_standards = true
  }
}

# Backup Configuration
variable "backup_config" {
  description = "Backup configuration for EKS cluster"
  type = object({
    enable_etcd_backup = bool
    backup_retention_days = number
    backup_schedule = string
  })
  default = {
    enable_etcd_backup = true
    backup_retention_days = 7
    backup_schedule = "cron(0 5 ? * * *)"  # Daily at 5 AM UTC
  }
}

# EKS Autoscaler Configuration
variable "autoscaler_config" {
  description = "EKS Cluster Autoscaler configuration"
  type = object({
    scale_down_enabled = bool
    scale_down_delay_after_add = string
    scale_down_unneeded = string
    max_node_provision_time = string
    scan_interval = string
    scale_down_utilization_threshold = string
    skip_nodes_with_local_storage = bool
    skip_nodes_with_system_pods = bool
    expander = string
    balance_similar_node_groups = bool
    max_total_unready_percentage = string
    ok_total_unready_count = string
  })
  default = {
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
}

variable "karpenter_limits" {
  description = "Resource limits for Karpenter nodes"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "100"
    memory = "100Gi"
  }
}

variable "availability_zones" {
  description = "List of availability zones for the Karpenter provisioner"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "default_instance_types" {
  description = "List of default instance types to use for Karpenter nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "m5.large"]
}

variable "external_dns_helm_chart_version" {
  description = "Version of the external-dns Helm chart"
  type        = string
  default     = "1.13.1"
}

variable "kube_prometheus_stack_helm_chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "55.5.0"
}