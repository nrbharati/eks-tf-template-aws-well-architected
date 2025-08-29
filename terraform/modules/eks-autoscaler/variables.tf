# Variables for EKS Auto Mode Module

variable "enable_autoscaler" {
  description = "Enable Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "openid_connect_provider_arn" {
  description = "ARN of the OIDC provider for service accounts"
  type        = string
}

variable "openid_connect_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "cluster_autoscaler_version" {
  description = "Version of Cluster Autoscaler Helm chart"
  type        = string
  default     = "9.35.0"
}

# Scaling configuration
variable "scale_down_enabled" {
  description = "Enable scale down of nodes"
  type        = bool
  default     = true
}

variable "scale_down_delay_after_add" {
  description = "How long after scale up that scale down evaluation resumes"
  type        = string
  default     = "10m"
}

variable "scale_down_unneeded" {
  description = "How long a node should be unneeded before it is eligible for scale down"
  type        = string
  default     = "10m"
}

variable "max_node_provision_time" {
  description = "Maximum time the autoscaler waits for a node to be provisioned"
  type        = string
  default     = "15m"
}

variable "scan_interval" {
  description = "How often cluster is reevaluated for scale up or down"
  type        = string
  default     = "10s"
}

variable "scale_down_utilization_threshold" {
  description = "Node utilization level below which a node can be considered for scale down"
  type        = string
  default     = "0.5"
}

variable "skip_nodes_with_local_storage" {
  description = "If true, cluster autoscaler will never delete nodes with pods with local storage"
  type        = bool
  default     = true
}

variable "skip_nodes_with_system_pods" {
  description = "If true, cluster autoscaler will never delete nodes with pods from kube-system"
  type        = bool
  default     = true
}

variable "expander" {
  description = "Type of node group expander to use"
  type        = string
  default     = "least-waste"
}

variable "balance_similar_node_groups" {
  description = "Detect similar node groups and balance the number of nodes between them"
  type        = bool
  default     = true
}

variable "max_total_unready_percentage" {
  description = "Maximum percentage of unready nodes in total"
  type        = string
  default     = "45"
}

variable "ok_total_unready_count" {
  description = "Number of allowed unready nodes"
  type        = string
  default     = "3"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
