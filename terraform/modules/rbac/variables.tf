variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
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

# Add AWS caller identity data source
data "aws_caller_identity" "current" {} 