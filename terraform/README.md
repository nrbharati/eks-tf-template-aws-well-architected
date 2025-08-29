# EKS Terraform Template

This Terraform template provides a comprehensive EKS infrastructure with the following features:

## Features

- EKS cluster with configurable node groups
- VPC CNI, CoreDNS, and kube-proxy add-ons
- EBS CSI driver for persistent storage
- ALB Controller for ingress management
- External DNS for automatic DNS record management
- EFS CSI driver (optional)
- Monitoring stack with Prometheus, Grafana, and Fluent Bit
- RBAC configuration with SSO integration
- Security groups and network policies
- Backup configuration for etcd
- **Karpenter for auto-scaling (optional)**

## Architecture

```
EKS Infrastructure
├── VPC & Networking
├── Security Groups
├── EKS Cluster
│   ├── Node Groups
│   └── Add-ons
├── Monitoring
│   ├── Prometheus
│   ├── Grafana
│   └── Fluent Bit
├── RBAC & Security
├── Backup
└── Karpenter (Optional)
    ├── Auto-scaling
    ├── Spot/On-demand instances
    └── Node consolidation
```

## Configuration

### Karpenter Configuration

Karpenter is now **optional** and can be enabled/disabled using the `enable_karpenter` variable:

```hcl
# Enable Karpenter (default: true)
enable_karpenter = true

# Disable Karpenter
enable_karpenter = false
```

When Karpenter is disabled:
- No Karpenter resources will be created
- Node group labels will not include Karpenter-specific tags
- IAM roles and policies for Karpenter will not be created
- The cluster will rely on EKS node groups for scaling

When Karpenter is enabled:
- Full Karpenter functionality including auto-scaling
- Spot and on-demand instance support
- Node consolidation and lifecycle management
- All Karpenter-related IAM resources

### Node Groups

Node groups are configured in `terraform.tfvars`:

```hcl
node_groups = {
  main = {
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3
      min_size     = 3
      max_size     = 5
    }
    labels = {
      "role" = "general"
      # Karpenter-specific labels are added automatically when enabled
    }
  }
}
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- helm
- aws-iam-authenticator

## Usage

1. Configure AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the execution plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Quick Start

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review the plan**
   ```bash
   terraform plan
   ```

3. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Preventing State Lock Issues

To avoid frequent state lock issues, use the provided state management script:

```bash
# Check for locks before operations
./scripts/manage-state.sh check

# Use safe commands that prevent conflicts
./scripts/manage-state.sh plan
./scripts/manage-state.sh apply

# If you get a lock, unlock it easily
./scripts/manage-state.sh unlock <lock_id>
```

### Why State Locks Happen
- **Concurrent operations** from multiple terminals
- **Interrupted commands** (Ctrl+C during long operations)
- **Long-running operations** (EKS cluster creation takes 15-20 minutes)
- **Network issues** during remote state operations

### Best Practices
1. **Always use the state management script** for major operations
2. **Wait for operations to complete** before running new commands
3. **Use `-auto-approve`** for long-running operations
4. **Check for running processes** before starting new operations

## Configuration

The template is highly configurable through variables. Key configuration options include:

- Cluster name and version
- Region and availability zones
- VPC CIDR and subnet configurations
- Node group configurations
- Karpenter settings
- Monitoring stack options
- Security group rules
- IAM role configurations

See `variables.tf` for all available configuration options.

## Security

The template implements several security best practices:

- Private subnets for worker nodes
- Security groups with least privilege
- IAM roles with minimal permissions
- Network policies for pod-to-pod communication
- Encryption at rest and in transit
- Regular security updates
- AWS CloudWatch monitoring and alerting

## Monitoring and Logging

The template includes:

- Prometheus for metrics collection
- Grafana for visualization
- AWS CloudWatch integration
- Container insights
- Log aggregation
- Alerting and notifications

## Backup and Recovery

- EBS volume backups
- Cluster state backup
- Disaster recovery procedures
- Multi-AZ deployment

## Maintenance

- Regular updates for EKS and add-ons
- Security patch management
- Resource cleanup procedures
- Cost optimization recommendations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 