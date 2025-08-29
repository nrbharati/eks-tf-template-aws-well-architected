# EKS Cluster Module

This module creates and manages an Amazon EKS cluster with associated resources.

## Overview

The EKS module is responsible for:
- Creating the EKS cluster
- Managing node groups
- Configuring cluster authentication
- Setting up cluster networking
- Managing cluster add-ons
- Configuring cluster logging and monitoring

## Features

1. **Cluster Management**
   - EKS cluster creation and configuration
   - Version management
   - Endpoint access control
   - Encryption configuration

2. **Node Groups**
   - Managed node groups
   - Spot instance support
   - Custom AMI support
   - Auto-scaling configuration

3. **Security**
   - IAM roles and policies
   - Security groups
   - Network policies
   - Encryption at rest

4. **Networking**
   - VPC integration
   - Subnet configuration
   - Endpoint access
   - Network policies

## Usage

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.32"
  
  vpc_id     = "vpc-XXXXXXXXX"
  subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]

  node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 5
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
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
| cluster_version | Kubernetes version | `string` | `"1.32"` | no |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| node_groups | Map of node group configurations | `map(any)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_endpoint | Endpoint for the EKS cluster |
| cluster_certificate_authority | Base64 encoded certificate authority data |
| cluster_iam_role_name | IAM role name of the EKS cluster |
| cluster_iam_role_arn | IAM role ARN of the EKS cluster |
| cluster_security_group_id | Security group ID of the EKS cluster |
| node_groups | Map of node group details |

## Node Group Configuration

Node groups can be configured with the following options:

```hcl
node_groups = {
  general = {
    desired_size = 2
    min_size     = 1
    max_size     = 5
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 50
    labels = {
      "node.kubernetes.io/role" = "general"
    }
    taints = []
  }
}
```

## Security Features

1. **IAM Integration**
   - Cluster IAM role
   - Node group IAM roles
   - Service account IAM roles

2. **Network Security**
   - Security groups
   - Network policies
   - Private endpoint access

3. **Encryption**
   - EBS volume encryption
   - Secrets encryption
   - Transit encryption

## Monitoring and Logging

- CloudWatch integration
- Container insights
- Control plane logging
- Node group metrics

## Maintenance

- Version updates
- Node group management
- Security patch management
- Resource cleanup

## Best Practices

1. **High Availability**
   - Multi-AZ deployment
   - Node group redundancy
   - Control plane redundancy

2. **Security**
   - Least privilege IAM roles
   - Network isolation
   - Regular security updates

3. **Cost Optimization**
   - Spot instance usage
   - Auto-scaling
   - Resource cleanup

4. **Performance**
   - Node group optimization
   - Network optimization
   - Storage optimization 