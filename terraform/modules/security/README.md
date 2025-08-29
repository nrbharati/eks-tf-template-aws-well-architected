# Security Module

This module manages security-related resources and configurations for the EKS cluster.

## Overview

The security module is responsible for:
- Managing security groups
- Configuring network policies
- Setting up pod security policies
- Managing encryption keys
- Configuring security monitoring
- Setting up audit logging
- Managing security compliance

## Features

1. **Security Groups**
   - Cluster security group
   - Node security group
   - Load balancer security group
   - Database security group

2. **Network Policies**
   - Pod-to-pod communication
   - Namespace isolation
   - Service access control
   - Ingress/Egress rules

3. **Pod Security**
   - Pod security policies
   - Security contexts
   - Runtime security
   - Container security

4. **Encryption**
   - KMS key management
   - Secret encryption
   - Volume encryption
   - Transit encryption

## Usage

```hcl
module "security" {
  source = "./modules/security"

  cluster_name = "my-cluster"
  vpc_id      = "vpc-XXXXXXXXX"
  
  # Security Group Configuration
  security_groups = {
    cluster = {
      name        = "eks-cluster-sg"
      description = "Security group for EKS cluster"
      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
  
  # Network Policy Configuration
  network_policies = {
    default-deny = {
      namespace = "default"
      policy_types = ["Ingress", "Egress"]
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
| vpc_id | ID of the VPC | `string` | n/a | yes |
| security_groups | Map of security group configurations | `map(any)` | `{}` | no |
| network_policies | Map of network policy configurations | `map(any)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_security_group_id | ID of the cluster security group |
| node_security_group_id | ID of the node security group |
| kms_key_arn | ARN of the KMS key |

## Security Group Configuration

Security groups can be configured with the following options:

```hcl
security_groups = {
  cluster = {
    name        = "eks-cluster-sg"
    description = "Security group for EKS cluster"
    ingress_rules = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
```

## Network Policy Configuration

Network policies can be configured with the following options:

```hcl
network_policies = {
  default-deny = {
    namespace = "default"
    policy_types = ["Ingress", "Egress"]
    pod_selector = {
      match_labels = {
        app = "my-app"
      }
    }
    ingress = [
      {
        from = [
          {
            pod_selector = {
              match_labels = {
                app = "allowed-app"
              }
            }
          }
        ]
      }
    ]
  }
}
```

## Security Features

1. **Access Control**
   - Security group rules
   - Network policies
   - Pod security policies

2. **Encryption**
   - KMS key management
   - Secret encryption
   - Volume encryption

3. **Monitoring**
   - Security monitoring
   - Audit logging
   - Compliance checks

## Best Practices

1. **Network Security**
   - Least privilege access
   - Network isolation
   - Security group rules

2. **Pod Security**
   - Security contexts
   - Runtime security
   - Container security

3. **Compliance**
   - Security standards
   - Audit requirements
   - Compliance checks

## Maintenance

1. **Security Updates**
   - Policy updates
   - Rule updates
   - Key rotation

2. **Monitoring**
   - Security monitoring
   - Log analysis
   - Compliance checks

3. **Backup and Recovery**
   - Key backup
   - Policy backup
   - Configuration backup

## Troubleshooting

1. **Security Group Issues**
   - Rule conflicts
   - Access problems
   - Configuration issues

2. **Network Policy Issues**
   - Policy conflicts
   - Access problems
   - Configuration issues

3. **Encryption Issues**
   - Key problems
   - Encryption errors
   - Access issues 