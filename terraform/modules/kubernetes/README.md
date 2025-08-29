# Kubernetes Module

This module manages Kubernetes resources and configurations for the EKS cluster.

## Overview

The Kubernetes module is responsible for:
- Deploying Kubernetes resources
- Managing Helm releases
- Configuring Karpenter for auto-scaling
- Setting up storage classes
- Managing network policies
- Configuring service accounts

## Features

1. **Karpenter Integration**
   - Auto-scaling configuration
   - Node provisioning
   - Spot instance support
   - Custom node templates

2. **Storage Management**
   - Storage class configuration
   - Persistent volume provisioning
   - Volume snapshot support
   - Backup configuration

3. **Network Configuration**
   - Network policies
   - Service mesh integration
   - Load balancer configuration
   - DNS management

4. **Resource Management**
   - Resource quotas
   - Limit ranges
   - Namespace configuration
   - Service account setup

## Usage

```hcl
module "kubernetes" {
  source = "./modules/kubernetes"

  cluster_name = "my-cluster"
  cluster_endpoint = "https://my-cluster.region.eks.amazonaws.com"
  cluster_certificate_authority = "base64-encoded-ca-cert"

  # Karpenter Configuration
  karpenter_version = "v0.36.0"
  karpenter_crd_chart_version = "v0.36.0"
  
  # Storage Configuration
  storage_classes = {
    gp3 = {
      type = "gp3"
      encrypted = true
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
| cluster_endpoint | Endpoint for the EKS cluster | `string` | n/a | yes |
| cluster_certificate_authority | Base64 encoded certificate authority data | `string` | n/a | yes |
| karpenter_version | Version of Karpenter | `string` | `"v0.36.0"` | no |
| karpenter_crd_chart_version | Version of Karpenter CRD chart | `string` | `"v0.36.0"` | no |
| storage_classes | Map of storage class configurations | `map(any)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| karpenter_namespace | Name of the Karpenter namespace |
| storage_class_names | List of created storage class names |

## Karpenter Configuration

Karpenter can be configured with the following options:

```hcl
karpenter_config = {
  version = "v0.36.0"
  settings = {
    aws = {
      defaultInstanceProfile = "KarpenterNodeInstanceProfile"
      isolatedVPC = true
    }
  }
  node_templates = {
    default = {
      subnet_selector = {
        "karpenter.sh/discovery" = "true"
      }
      security_group_selector = {
        "karpenter.sh/discovery" = "true"
      }
    }
  }
}
```

## Storage Class Configuration

Storage classes can be configured with the following options:

```hcl
storage_classes = {
  gp3 = {
    type = "gp3"
    encrypted = true
    parameters = {
      type = "gp3"
      encrypted = "true"
      iopsPerGB = "3000"
      throughputPerGB = "125"
    }
  }
}
```

## Security Features

1. **Network Policies**
   - Pod-to-pod communication
   - Namespace isolation
   - Service access control

2. **Resource Security**
   - Resource quotas
   - Limit ranges
   - Pod security policies

3. **Access Control**
   - Service accounts
   - Role-based access
   - Network policies

## Best Practices

1. **Auto-scaling**
   - Karpenter configuration
   - Node provisioning
   - Spot instance usage

2. **Storage Management**
   - Storage class configuration
   - Volume provisioning
   - Backup strategy

3. **Network Security**
   - Network policies
   - Service mesh
   - Load balancer configuration

## Maintenance

1. **Version Management**
   - Karpenter updates
   - Storage class updates
   - Resource updates

2. **Resource Cleanup**
   - Unused resources
   - Orphaned volumes
   - Old configurations

3. **Monitoring**
   - Resource usage
   - Performance metrics
   - Health checks

## Troubleshooting

1. **Karpenter Issues**
   - Node provisioning
   - Spot instance usage
   - Configuration problems

2. **Storage Issues**
   - Volume provisioning
   - Storage class problems
   - Backup issues

3. **Network Issues**
   - Policy conflicts
   - Service connectivity
   - Load balancer problems 