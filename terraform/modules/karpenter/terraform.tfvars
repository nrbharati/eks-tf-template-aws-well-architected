# Cluster Information
cluster_name = "eks-frontend-cluster"
cluster_endpoint = "https://CLUSTER_ENDPOINT.REGION.eks.amazonaws.com"
cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJWHp0dysrSGNSYk13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ua3hOalF5TVRKYUZ3MHpOVEEyTVRjeE5qUTNNVEphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURMU0pnOEx4SHZvVW5nblh1UXduMXpkczZPSzdHRHFrTHI5SFczOHNlTC9nbnRaNmF0NDdNcTRvWUgKNjlIdXBBTm4yYmFGdFhodmZLZHc4amQyZmg2MEpacHlvb2J4amxRWElaS2tiZXo5ajVsSERUOTlYUE82aWFGRgpuMDdFY1p6L2tOblZCZDYrL2dEanBiTDlsLzhUOHpBVWpvY3JjYzA4UGZBU3ZzTjNVMEdHeThvb3VmcFJCVU5YCjBxMm1DV3EwN3JXOUNnSzRybmNUY3JnbzJheXNQdE5xcm93cW5saHZQQ0JBbTdMenY0MERKdS94L3BYRTljdzAKaGYxYmpLdlh1THc5VmNjQlJMMVdJcTBBekwyUDMrTUNQdmRsYVBsYnhzcEpJNWhoUFZtdm5OSEpidkc2UDhhSgo3Nmo3bTl3OGV3OUNQdFMwN1BHTHhKdHV5a09qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRaXNLbnRvbU44c2V6Yy9iSVgxYjg4ZmNLSjF6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ3hRUTlLRmJ4VQpTeW40VFlsRVhlMTA4R2N5cHFIRkl3bXZyQjYzRlJTRDBtcDR0Z1c0R0FTWFlXcXRqNCtsWHd3cXl6cjkyYXZCCk92WlZWY2Z6Z055RGJZQTVhNklkb1NCdE03dm5WVnc0aFdWYWlTSFVidmZudUMxdnVkZGxkSGZrVTd0Ymt6K1EKblNKWEJ3MEJ1VXdPaW1WRENSTlVSWjR0VHRLYSs3VXRwZVZWWkZMN0Z3LzE0amFkaGZHQmowdGVIeGRCWnpFcgp4NXc2bDIwcHBqaWtDM3NDSjB3T28wYU1KUktNRzNpZUJCMVl2b0pKTXBDZUU0WlVIc056ZHRFYzRSS29tcVVJCm1FUnF2NkIxeHBiSGtKbWgrZ0pvYkdSaEZsY09jSm9BcEphTS9vOXFWSThIWHpLeThmbWMzRURGY0pUa0FrMmoKSmU3aFVWN3dmQWsvCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"

# VPC and Subnet Configuration
vpc_id = "vpc-XXXXXXXXX"
private_subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]

# Security Group Configuration
node_security_group_id = "sg-XXXXXXXXX"

# OIDC Provider Information
openid_connect_provider_arn = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/OIDC_PROVIDER_ID"
openid_connect_provider_url = "oidc.eks.us-east-1.amazonaws.com/id/OIDC_PROVIDER_ID"

# Karpenter Configuration
karpenter_version = "0.36.0"
instance_types = [
  "t3.medium", "t3.large", "t3.xlarge",
  "m5.large", "m5.xlarge", "m5.2xlarge",
  "c5.large", "c5.xlarge", "c5.2xlarge"
]
capacity_types = ["on-demand", "spot"]
consolidation_enabled = true

# Resource Limits
max_cpu = "1000"
max_memory = "1000Gi"

# Node Configuration
node_labels = {
  "karpenter.sh/capacity-type" = "spot"
  "node.kubernetes.io/instance-type" = "spot"
}

# Monitoring
enable_metrics_server = true
enable_cloudwatch_logs = true
enable_ssm_access = true

# CSI Drivers
enable_ebs_csi_driver = true
enable_efs_csi_driver = false

# Tags
tags = {
  Environment = "non-prod"
  Project     = "eks-framework"
  Owner       = "DevOps"
  Group       = "Nikhil Bharati"
} 