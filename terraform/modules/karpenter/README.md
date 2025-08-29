# Karpenter Module v0.37

This module deploys Karpenter v0.37.0 for auto-scaling worker nodes on an existing EKS cluster. Karpenter automatically provisions the right compute resources to handle your cluster's applications.

## Overview

Karpenter is a Kubernetes autoscaler that automatically provisions the right compute resources to handle your cluster's applications. It is designed to work with any Kubernetes cluster and can automatically provision nodes based on pod requirements.

## Features

- **Auto-scaling**: Automatically provisions nodes based on pod requirements
- **Spot Instance Support**: Can use spot instances for cost optimization
- **Multiple Instance Types**: Supports a wide range of EC2 instance types
- **Node Consolidation**: Automatically consolidates underutilized nodes
- **AL2 Support**: Optimized for Amazon Linux 2
- **EKS Compatible**: Tested with EKS clusters
- **Monitoring Integration**: Includes Prometheus metrics and ServiceMonitors
- **SSM Access**: Optional SSM access for node management
- **CloudWatch Integration**: Optional CloudWatch logs and metrics

## Prerequisites

1. **Existing EKS Cluster**: This module requires an existing EKS cluster
2. **OIDC Provider**: The cluster must have an OIDC provider configured
3. **VPC and Subnets**: Private subnets must be tagged for Karpenter discovery
4. **IAM Permissions**: Proper IAM roles and policies must be configured

## Terraform Deployment Steps

### Step 1: Get Cluster Information

First, get the required information from your existing EKS cluster:

```bash
# Get cluster endpoint and certificate authority data
aws eks describe-cluster --name eks-frontend-cluster --region us-east-1 --query 'cluster.{endpoint:endpoint,certificateAuthorityData:certificateAuthority.data}'

# Get OIDC provider ARN
aws eks describe-cluster --name eks-frontend-cluster --region us-east-1 --query 'cluster.identity.oidc.issuer' --output text

# Get node security group ID
aws eks describe-cluster --name eks-frontend-cluster --region us-east-1 --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text
```

### Step 2: Configure Variables

Update the `terraform.tfvars` file with your cluster information:

```hcl
cluster_name = "your-cluster-name"
cluster_endpoint = "https://your-cluster.region.eks.amazonaws.com"
cluster_certificate_authority_data = "base64-encoded-ca-cert"
aws_region = "us-east-1"
vpc_id = "vpc-XXXXXXXXX"
private_subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]
node_security_group_id = "sg-XXXXXXXXX"
openid_connect_provider_arn = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.region.amazonaws.com/id/ABCDEF123456"
openid_connect_provider_url = "oidc.eks.region.amazonaws.com/id/ABCDEF123456"
```

### Step 3: Deploy the Module

```bash
cd terraform/modules/karpenter
terraform init
terraform plan
terraform apply
```

## Usage

### Basic Configuration

```hcl
module "karpenter" {
  source = "./modules/karpenter"

  cluster_name                    = "my-eks-cluster"
  cluster_endpoint                = "https://my-cluster.region.eks.amazonaws.com"
  cluster_certificate_authority_data = "base64-encoded-ca-cert"
  aws_region                      = "us-east-1"
  vpc_id                          = "vpc-XXXXXXXXX"
  private_subnet_ids              = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]
  node_security_group_id          = "sg-XXXXXXXXX"
  openid_connect_provider_arn     = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.region.amazonaws.com/id/ABCDEF123456"
  openid_connect_provider_url     = "oidc.eks.region.amazonaws.com/id/ABCDEF123456"
}
```

### Advanced Configuration

```hcl
module "karpenter" {
  source = "./modules/karpenter"

  cluster_name                    = "my-eks-cluster"
  cluster_endpoint                = "https://my-cluster.region.eks.amazonaws.com"
  cluster_certificate_authority_data = "base64-encoded-ca-cert"
  aws_region                      = "us-east-1"
  vpc_id                          = "vpc-XXXXXXXXX"
  private_subnet_ids              = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]
  node_security_group_id          = "sg-XXXXXXXXX"
  openid_connect_provider_arn     = "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.region.amazonaws.com/id/ABCDEF123456"
  openid_connect_provider_url     = "oidc.eks.region.amazonaws.com/id/ABCDEF123456"

  # Karpenter Configuration
  karpenter_version               = "0.37.0"
  instance_types                  = ["t3.medium", "t3.large", "t3.xlarge", "m5.large", "c5.large"]
  capacity_types                  = ["on-demand", "spot"]
  consolidation_enabled           = true
  ttl_seconds_after_empty         = 300
  ttl_seconds_until_expired       = 2592000

  # Resource Limits
  max_cpu                         = "1000"
  max_memory                      = "1000Gi"

  # Node Configuration
  node_labels = {
    "karpenter.sh/capacity-type" = "spot"
    "node.kubernetes.io/instance-type" = "spot"
  }

  # Monitoring
  enable_metrics_server           = true
  enable_cloudwatch_logs          = true
  enable_ssm_access               = true

  # CSI Drivers
  enable_ebs_csi_driver           = true
  enable_efs_csi_driver           = false

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
| cluster_certificate_authority_data | Base64 encoded certificate authority data | `string` | n/a | yes |
| aws_region | AWS region | `string` | `"us-east-1"` | no |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| private_subnet_ids | List of private subnet IDs | `list(string)` | n/a | yes |
| node_security_group_id | Security group ID for nodes | `string` | n/a | yes |
| openid_connect_provider_arn | ARN of the OIDC provider | `string` | n/a | yes |
| openid_connect_provider_url | URL of the OIDC provider | `string` | n/a | yes |
| karpenter_version | Version of Karpenter | `string` | `"0.37.0"` | no |
| instance_types | List of instance types | `list(string)` | See variables.tf | no |
| capacity_types | Capacity types to use | `list(string)` | `["on-demand", "spot"]` | no |
| consolidation_enabled | Enable node consolidation | `bool` | `true` | no |
| ttl_seconds_after_empty | TTL after node becomes empty | `number` | `300` | no |
| ttl_seconds_until_expired | TTL until node expires | `number` | `2592000` | no |
| max_cpu | Maximum CPU cores | `string` | `"1000"` | no |
| max_memory | Maximum memory | `string` | `"1000Gi"` | no |
| availability_zones | List of availability zones | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| node_labels | Labels to apply to nodes | `map(string)` | See variables.tf | no |
| node_taints | Taints to apply to nodes | `list(object)` | `[]` | no |
| enable_spot_termination_handling | Enable spot termination handling | `bool` | `true` | no |
| enable_aws_node_termination_handler | Enable AWS Node Termination Handler | `bool` | `true` | no |
| enable_metrics_server | Enable metrics server | `bool` | `true` | no |
| enable_cloudwatch_logs | Enable CloudWatch logs | `bool` | `true` | no |
| enable_ssm_access | Enable SSM access | `bool` | `true` | no |
| enable_ebs_csi_driver | Enable EBS CSI driver | `bool` | `true` | no |
| enable_efs_csi_driver | Enable EFS CSI driver | `bool` | `false` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| karpenter_namespace | Name of the Karpenter namespace |
| karpenter_node_role_arn | ARN of the IAM role for Karpenter nodes |
| karpenter_node_role_name | Name of the IAM role for Karpenter nodes |
| karpenter_controller_role_arn | ARN of the IAM role for Karpenter controller |
| karpenter_controller_role_name | Name of the IAM role for Karpenter controller |
| karpenter_instance_profile_arn | ARN of the IAM instance profile for Karpenter nodes |
| karpenter_instance_profile_name | Name of the IAM instance profile for Karpenter nodes |
| karpenter_ec2_policy_arn | ARN of the EC2 policy for Karpenter |
| karpenter_ec2_policy_name | Name of the EC2 policy for Karpenter |

## Karpenter Resources

This module creates the following Karpenter resources:

1. **AWSNodeTemplate**: Defines the node template with AMI, security groups, and subnets
2. **Provisioner**: Defines the provisioning rules and limits

### AWSNodeTemplate

The AWSNodeTemplate defines:
- AMI family (AL2)
- Instance profile
- Block device mappings
- Security group selectors
- Subnet selectors

### Provisioner

The Provisioner defines:
- Resource limits (CPU and memory)
- Instance requirements (category, generation, architecture, OS)
- Capacity types (on-demand and spot)
- Consolidation settings
- TTL settings

## IAM Roles and Policies

The module creates the following IAM resources:

1. **Karpenter Node Role**: Role for Karpenter-provisioned nodes
2. **Karpenter Controller Role**: Role for the Karpenter controller
3. **EC2 Policy**: Custom policy with required EC2 permissions
4. **Instance Profile**: Instance profile for Karpenter nodes

## Security Features

1. **IAM Roles**: Separate roles for nodes and controller
2. **OIDC Integration**: Service account integration with AWS IAM
3. **Security Groups**: Proper security group configuration
4. **Encryption**: EBS volume encryption enabled by default

## Monitoring and Logging

1. **Prometheus Metrics**: Karpenter exposes metrics for monitoring
2. **CloudWatch Logs**: Optional CloudWatch log integration
3. **SSM Access**: Optional SSM access for node management

## Best Practices

1. **Resource Limits**: Set appropriate CPU and memory limits
2. **Instance Types**: Use a variety of instance types for flexibility
3. **Spot Instances**: Use spot instances for cost optimization
4. **Consolidation**: Enable consolidation to reduce costs
5. **TTL Settings**: Configure appropriate TTL settings
6. **Security**: Use proper IAM roles and security groups

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure IAM roles have proper permissions
2. **Node Provisioning Failures**: Check subnet and security group configuration
3. **Spot Instance Failures**: Verify spot instance availability in your region
4. **Consolidation Issues**: Check consolidation settings and pod disruption budgets

### Debugging Commands

```bash
# Check Karpenter pods
kubectl get pods -n karpenter

# Check Karpenter logs
kubectl logs -n karpenter deployment/karpenter

# Check AWSNodeTemplate status
kubectl get awsnodetemplate

# Check Provisioner status
kubectl get provisioner

# Check node events
kubectl get events --sort-by='.lastTimestamp'
```

## Maintenance

1. **Version Updates**: Update Karpenter version as needed
2. **Resource Cleanup**: Monitor and clean up unused resources
3. **Cost Optimization**: Review and adjust resource limits and consolidation settings
4. **Security Updates**: Keep IAM policies and security groups updated

## License

This module is licensed under the MIT License. 