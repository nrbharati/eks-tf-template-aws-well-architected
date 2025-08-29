# Variables for EKS Auto Mode Module

variable "prometheus_helm_chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for the cluster"
  type        = string
}

variable "grafana_ingress_class" {
  description = "Ingress class name to use"
  type        = string
  default     = "alb"
}

variable "enable_monitoring" {
  description = "Enable monitoring resources"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "fluentbit_helm_chart_version" {
  description = "Version of the Fluent Bit Helm chart"
  type        = string
}

variable "openid_connect_provider_arn" {
  description = "ARN of the OIDC Provider"
  type        = string
}

variable "openid_connect_provider_url" {
  description = "URL of the OIDC Provider"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# New variables for ingress configuration
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

variable "grafana_hostname" {
  description = "Hostname for Grafana ingress (if not using domain_name)"
  type        = string
  default     = null
}