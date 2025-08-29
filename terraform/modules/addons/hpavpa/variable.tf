variable "hpa_min_replicas" {
  description = "Minimum number of replicas for HPA"
  type        = number
  default     = 1
}

variable "hpa_max_replicas" {
  description = "Maximum number of replicas for HPA"
  type        = number
  default     = 10
}

variable "hpa_cpu_target_utilization" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
  default     = 80
}

variable "hpa_memory_target_utilization" {
  description = "Target memory utilization percentage for HPA"
  type        = number
  default     = 80
}

variable "vpa_min_cpu" {
  description = "Minimum CPU resource for VPA"
  type        = string
  default     = "100m"
}

variable "vpa_min_memory" {
  description = "Minimum memory resource for VPA"
  type        = string
  default     = "128Mi"
}

variable "vpa_max_cpu" {
  description = "Maximum CPU resource for VPA"
  type        = string
  default     = "1000m"
}

variable "vpa_max_memory" {
  description = "Maximum memory resource for VPA"
  type        = string
  default     = "1Gi"
}

variable "vpa_helm_chart_version" {
  type        = string
  description = "Version of the vpa Helm chart"
  default     = "4.7.0" 
}