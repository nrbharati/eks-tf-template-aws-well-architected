variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string  
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
  default     = "v1.19.2-eksbuild.5"
}

variable "coredns_version" {
  description = "Version of the CoreDNS add-on"
  type        = string
  default     = "v1.11.4-eksbuild.2"
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on"
  type        = string
  default     = "v1.30.9-eksbuild.3"
}

variable "metrics_server_helm_chart_version" {
  type        = string
  description = "Version of the metrics-server Helm chart"
  default     = "3.8.3"  
}

variable "openid_connect_provider_arn" {
  type        = string
  description = "ARN of the IAM OpenID Connect provider"
}

variable "openid_connect_provider_url" {
  type        = string
  description = "URL of the IAM OpenID Connect provider"
}

variable "external_dns_chart_version" {
  type        = string
  description = "Version of the external-dns Helm chart"
  default     = "1.14.3"
}

variable "alb_controller_helm_chart_version" {
  type        = string
  description = "Version of the ALB Ingress Controller Helm chart"
  default     = "1.7.1"
  
}

variable "domain_name" {
  type        = string
  description = "Domain name for the cluster"
}

variable "enable_efs_driver" {
  type        = bool
  description = "Enable the EFS CSI driver"
  default     = false
}

variable "enable_ebs_driver" {
  type        = bool
  description = "Enable the EBS CSI driver"
  default     = true
}

variable "efs_csi_driver_chart_version" {
  type        = string
  description = "Version of the EFS CSI driver Helm chart"
  default     = "2.5.1"
}

variable "ebs_csi_driver_chart_version" {
  description = "Version of the EBS CSI Driver addon"
  type        = string
  default     = "v1.44.0-eksbuild.1"
} 

 