# IAM Module

This module manages IAM roles, policies, and service accounts for the EKS cluster and its components.

## Overview

The IAM module is responsible for:
- Creating IAM roles for the EKS cluster
- Managing IAM policies for cluster components
- Setting up service accounts with IAM roles
- Configuring OIDC provider for EKS
- Managing permissions for add-ons and applications

## Features

1. **Cluster IAM Roles**
   - EKS cluster role
   - Node group roles
   - Service account roles

2. **Policy Management**
   - Custom policy creation
   - Policy attachments
   - Policy versioning

3. **Service Account Integration**
   - OIDC provider setup
   - Service account creation
   - Role binding

4. **Permission Management**
   - Least privilege access
   - Role-based access control
   - Policy inheritance

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  cluster_name = "my-cluster"
  
  # OIDC Provider Configuration
  create_oidc_provider = true
  oidc_provider_url    = "oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  
  # Service Account Roles
  service_account_roles = {
    "kube-system/aws-load-balancer-controller" = {
      policy_arns = ["arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"]
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| create_oidc_provider | Whether to create OIDC provider | `bool` | `true` | no |
| oidc_provider_url | URL of the OIDC provider | `string` | n/a | yes |
| service_account_roles | Map of service account roles | `map(any)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_role_arn | ARN of the EKS cluster IAM role |
| node_group_role_arn | ARN of the node group IAM role |
| oidc_provider_arn | ARN of the OIDC provider |
| service_account_roles | Map of service account role ARNs |

## Service Account Configuration

Service accounts can be configured with the following options:

```hcl
service_account_roles = {
  "kube-system/aws-load-balancer-controller" = {
    policy_arns = ["arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"]
    role_name   = "aws-load-balancer-controller"
    tags = {
      Service = "aws-load-balancer-controller"
    }
  }
}
```

## Security Features

1. **Role-Based Access Control**
   - Service account roles
   - Policy attachments
   - Permission boundaries

2. **Policy Management**
   - Custom policies
   - Managed policies
   - Policy versioning

3. **OIDC Integration**
   - Provider configuration
   - Token authentication
   - Role assumption

## Best Practices

1. **Least Privilege**
   - Minimal required permissions
   - Policy scoping
   - Regular permission review

2. **Security**
   - Policy encryption
   - Access logging
   - Regular audits

3. **Maintenance**
   - Policy updates
   - Role cleanup
   - Permission reviews

## Common Use Cases

1. **Add-on Integration**
   - AWS Load Balancer Controller
   - External DNS
   - EBS CSI Driver

2. **Application Access**
   - S3 bucket access
   - DynamoDB access
   - RDS access

3. **Monitoring and Logging**
   - CloudWatch access
   - X-Ray access
   - CloudTrail access

## Troubleshooting

1. **Permission Issues**
   - Check policy attachments
   - Verify role assumptions
   - Review trust relationships

2. **OIDC Issues**
   - Verify provider configuration
   - Check token validation
   - Review role bindings

3. **Service Account Issues**
   - Verify annotations
   - Check role bindings
   - Review permissions 