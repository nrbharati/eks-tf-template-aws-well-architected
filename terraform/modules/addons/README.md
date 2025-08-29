# EKS Addons Module

This module manages EKS add-ons and their associated IAM roles and policies.

## Overview

The addons module is responsible for:
- Installing and managing EKS add-ons
- Creating IAM roles and policies for add-ons
- Configuring service accounts for add-ons
- Managing add-on versions and configurations

## Supported Add-ons

1. **EBS CSI Driver**
   - Manages EBS volumes in EKS
   - Provides persistent storage capabilities
   - Includes IAM roles for EBS operations

2. **AWS Load Balancer Controller**
   - Manages AWS Load Balancers
   - Handles ingress resources
   - Configures ALB/NLB for services

3. **External DNS**
   - Manages DNS records in Route53
   - Automates DNS record creation/deletion
   - Supports multiple DNS providers

## Usage

```hcl
module "addons" {
  source = "./modules/addons"

  cluster_name                    = "my-cluster"
  cluster_endpoint               = "https://my-cluster.region.eks.amazonaws.com"
  cluster_certificate_authority  = "base64-encoded-ca-cert"
  openid_connect_provider_arn    = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  openid_connect_provider_url    = "oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  
  ebs_csi_driver_chart_version   = "v1.30.0"
  aws_load_balancer_version      = "v2.7.1"
  external_dns_chart_version     = "1.13.1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_endpoint | Endpoint for the EKS cluster | `string` | n/a | yes |
| cluster_certificate_authority | Base64 encoded certificate authority data | `string` | n/a | yes |
| openid_connect_provider_arn | ARN of the OIDC provider | `string` | n/a | yes |
| openid_connect_provider_url | URL of the OIDC provider | `string` | n/a | yes |
| ebs_csi_driver_chart_version | Version of the EBS CSI driver | `string` | `"v1.30.0"` | no |
| aws_load_balancer_version | Version of the AWS Load Balancer Controller | `string` | `"v2.7.1"` | no |
| external_dns_chart_version | Version of External DNS | `string` | `"1.13.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ebs_csi_driver_role_arn | ARN of the EBS CSI driver IAM role |
| aws_load_balancer_role_arn | ARN of the AWS Load Balancer Controller IAM role |
| external_dns_role_arn | ARN of the External DNS IAM role |

## IAM Roles and Policies

The module creates the following IAM roles and policies:

1. **EBS CSI Driver Role**
   - Permissions for EBS volume operations
   - Service account integration

2. **AWS Load Balancer Controller Role**
   - Permissions for ALB/NLB management
   - Service account integration

3. **External DNS Role**
   - Permissions for Route53 operations
   - Service account integration

## Security Considerations

- All IAM roles follow the principle of least privilege
- Service accounts are created in the kube-system namespace
- OIDC provider integration for secure token authentication
- Regular updates for add-on versions

## Maintenance

- Regular version updates for add-ons
- Monitoring of add-on health
- Backup of add-on configurations
- Cleanup procedures for unused resources 