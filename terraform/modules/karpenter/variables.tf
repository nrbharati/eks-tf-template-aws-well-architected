variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Karpenter nodes"
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Security group ID for Karpenter nodes"
  type        = string
}

variable "openid_connect_provider_arn" {
  description = "ARN of the OIDC provider for service accounts"
  type        = string
}

variable "openid_connect_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "0.36.0"
}

variable "instance_types" {
  description = "List of instance types that Karpenter can provision"
  type        = list(string)
  default = [
    "t3.medium", "t3.large", "t3.xlarge",
    "m5.large", "m5.xlarge", "m5.2xlarge",
    "c5.large", "c5.xlarge", "c5.2xlarge",
    "r5.large", "r5.xlarge", "r5.2xlarge"
  ]
}

variable "capacity_types" {
  description = "Capacity types that Karpenter can use"
  type        = list(string)
  default     = ["on-demand", "spot"]
}

variable "consolidation_enabled" {
  description = "Enable node consolidation"
  type        = bool
  default     = true
}

variable "ttl_seconds_after_empty" {
  description = "TTL in seconds after node becomes empty"
  type        = number
  default     = 300
}

variable "ttl_seconds_until_expired" {
  description = "TTL in seconds until node expires"
  type        = number
  default     = 2592000 # 30 days
}

variable "max_cpu" {
  description = "Maximum CPU cores that Karpenter can provision"
  type        = string
  default     = "1000"
}

variable "max_memory" {
  description = "Maximum memory that Karpenter can provision"
  type        = string
  default     = "1000Gi"
}

variable "availability_zones" {
  description = "List of availability zones for Karpenter nodes"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "node_labels" {
  description = "Labels to apply to Karpenter nodes"
  type        = map(string)
  default = {
    "karpenter.sh/capacity-type" = "spot"
    "node.kubernetes.io/instance-type" = "spot"
  }
}

variable "node_taints" {
  description = "Taints to apply to Karpenter nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "enable_spot_termination_handling" {
  description = "Enable spot termination handling"
  type        = bool
  default     = true
}

variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler"
  type        = bool
  default     = true
}

variable "aws_node_termination_handler_version" {
  description = "Version of AWS Node Termination Handler"
  type        = string
  default     = "1.20.5"
}

variable "enable_metrics_server" {
  description = "Enable metrics server for Karpenter"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Version of metrics server"
  type        = string
  default     = "6.4.0"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for Karpenter"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "enable_ssm_access" {
  description = "Enable SSM access for Karpenter nodes"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch agent on Karpenter nodes"
  type        = bool
  default     = true
}

variable "enable_efs_csi_driver" {
  description = "Enable EFS CSI driver"
  type        = bool
  default     = false
}

variable "efs_csi_driver_version" {
  description = "Version of EFS CSI driver"
  type        = string
  default     = "2.5.1"
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_version" {
  description = "Version of EBS CSI driver"
  type        = string
  default     = "2.20.0"
} 