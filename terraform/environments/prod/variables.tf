# Production Environment Variables for EKS Terraform Configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
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
  default     = "eks-prod-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI Helm chart"
  type        = string
  default     = "v1.20.1-eksbuild.1"
}

variable "coredns_version" {
  description = "Version of the CoreDNS Helm chart"
  type        = string
  default     = "v1.12.2-eksbuild.4"
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy Helm chart"
  type        = string
  default     = "v1.33.3-eksbuild.4"
}

variable "enable_karpenter" {
  description = "Enable Karpenter for node autoscaling"
  type        = bool
  default     = false
}

variable "enable_eks_autoscaler" {
  description = "Enable EKS Cluster Autoscaler for node autoscaling"
  type        = bool
  default     = true
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
      instance_types = ["t3.large", "t3.xlarge", "c5.4xlarge"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 3
        min_size     = 3
        max_size     = 10
      }
      labels = {
        "role"        = "general"
        "environment" = "production"
      }
      taints = []
    }
  }
}

variable "cluster_config" {
  description = "EKS cluster configuration"
  type = object({
    endpoint_private_access   = bool
    endpoint_public_access    = bool
    enabled_cluster_log_types = list(string)
  })
  default = {
    endpoint_private_access   = true
    endpoint_public_access    = false
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
}

variable "enable_efs_driver" {
  description = "Enable EFS CSI driver"
  type        = bool
  default     = true
}

variable "enable_ebs_driver" {
  description = "Enable EBS CSI driver"
  type        = bool
  default     = false
}

variable "external_dns_chart_version" {
  description = "External DNS Helm chart version"
  type        = string
  default     = "1.16.1"
}

variable "alb_controller_helm_chart_version" {
  description = "ALB Controller Helm chart version"
  type        = string
  default     = "1.13.2"
}

variable "fluentbit_helm_chart_version" {
  description = "Fluent Bit Helm chart version"
  type        = string
  default     = "0.46.6"
}

variable "karpenter_version" {
  description = "Karpenter version"
  type        = string
  default     = "0.36.0"
}

variable "karpenter_instance_types" {
  description = "Instance types for Karpenter"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge", "c5.large", "c5.xlarge"]
}

variable "karpenter_capacity_types" {
  description = "Capacity types that Karpenter can use"
  type        = list(string)
  default     = ["on-demand"]
}

variable "karpenter_limits" {
  description = "Karpenter resource limits"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "200"
    memory = "200Gi"
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_admin_user" {
  description = "Grafana admin user"
  type        = string
  default     = "admin"
}

variable "grafana_hostname" {
  description = "Grafana hostname"
  type        = string
}

variable "grafana_ingress_class" {
  description = "Grafana ingress class"
  type        = string
  default     = "alb"
}

variable "prometheus_helm_chart_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "75.0.0"
}

variable "metrics_server_helm_chart_version" {
  description = "Metrics Server Helm chart version"
  type        = string
  default     = "3.12.2"
}

variable "vpa_helm_chart_version" {
  description = "VPA Helm chart version"
  type        = string
  default     = "4.7.0"
}

variable "domain_name" {
  description = "Domain name for external DNS"
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

variable "ssh_key_name" {
  description = "SSH key pair name for EKS nodes"
  type        = string
  default     = "EKS_KP_PROD"
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

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "eks-framework"
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    Owner = "DevOps"
    Group = "Production Team"
  }
}

variable "enable_backup" {
  description = "Enable backup for production"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

variable "backup_schedule" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "monitoring_config" {
  description = "Enhanced monitoring configuration"
  type = object({
    enable_container_insights = bool
    log_retention_days        = number
    metrics_retention_days    = number
  })
  default = {
    enable_container_insights = true
    log_retention_days        = 30
    metrics_retention_days    = 15
  }
}

variable "pod_security_config" {
  description = "Pod security configuration"
  type = object({
    enable_psp                    = bool
    enable_network_policy         = bool
    enable_pod_security_standards = bool
  })
  default = {
    enable_psp                    = true
    enable_network_policy         = true
    enable_pod_security_standards = true
  }
}
