variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  type        = string
}

variable "enable_karpenter" {
  description = "Enable Karpenter resources"
  type        = bool
  default     = true
}

variable "node_role_arn" {
  description = "ARN of the IAM role for EKS nodes (deprecated, use karpenter_node_role_arn instead)"
  type        = string
  default     = null
}

variable "karpenter_node_role_arn" {
  description = "ARN of the IAM role for Karpenter nodes"
  type        = string
  default     = null
}

variable "prometheus_stack_dependency" {
  description = "Dependency on Prometheus stack to ensure ServiceMonitor CRDs are available"
  type        = any
  default     = null
}

variable "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter controller"
  type        = string
}

variable "karpenter_instance_profile_name" {
  description = "Name of the IAM instance profile for Karpenter nodes"
  type        = string
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "0.16.2"
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

variable "karpenter_instance_types" {
  description = "List of instance types that Karpenter can provision"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge"]
}

variable "karpenter_cpu_requirements" {
  description = "CPU requirements for Karpenter nodes"
  type        = list(string)
  default     = ["2", "4", "8"]
}

variable "karpenter_memory_requirements" {
  description = "Memory requirements for Karpenter nodes"
  type        = list(string)
  default     = ["4Gi", "8Gi", "16Gi"]
}

variable "karpenter_capacity_types" {
  description = "Capacity types that Karpenter can use"
  type        = list(string)
  default     = ["on-demand", "spot"]
} 