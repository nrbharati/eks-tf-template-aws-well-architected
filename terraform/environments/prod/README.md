# Production Environment Deployment Guide

This directory contains the Terraform configuration for deploying a production EKS cluster using the shared framework.

## Prerequisites

1. **AWS CLI Configuration**: Ensure you have AWS CLI configured with a production profile
2. **Terraform**: Version 1.0 or higher
3. **Production Infrastructure**: VPC, subnets, and other networking resources must exist
4. **Domain Configuration**: Production domain must be configured in Route53

## Configuration Steps

### 1. Update Production Values

Edit `terraform.tfvars` and update the following values:

```hcl
# Production VPC and Subnet IDs
vpc_id = "vpc-XXXXXXXXX"  # Your production VPC ID
private_subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]
public_subnet_ids = ["subnet-XXXXXXXXX", "subnet-XXXXXXXXX", "subnet-XXXXXXXXX"]

# Production Domain
domain_name = "production.yourdomain.com"
grafana_hostname = "grafana.production.yourdomain.com"

# Secure Password
grafana_admin_password = "YOUR_SECURE_PASSWORD"
```

### 2. Configure AWS Profile

Update `providers.tf` with your production AWS profile:

```hcl
provider "aws" {
  region  = var.aws_region
  profile = "your-production-profile"  # Change this
}
```

### 3. Initialize Terraform

```bash
cd terraform/environments/prod
terraform init
```

### 4. Create and Switch to Production Workspace

```bash
# Create production workspace
terraform workspace new prod

# Switch to production workspace
terraform workspace select prod

# Verify current workspace
terraform workspace show
```

### 5. Plan Deployment

```bash
terraform plan -out=production-plan.tfplan
```

### 6. Deploy

```bash
terraform apply production-plan.tfplan
```

## Production-Specific Features

- **Enhanced Security**: Private endpoint access only
- **Robust Node Groups**: Multiple instance types for high availability
- **Production Monitoring**: Full monitoring stack with Grafana
- **Compliance Tags**: Production-specific tagging for cost and compliance
- **Backup Strategy**: Daily backup configuration

## Security Considerations

1. **Network Security**: Production cluster uses private endpoints only
2. **IAM Roles**: Strict IAM policies for production workloads
3. **Encryption**: All data encrypted at rest and in transit
4. **Monitoring**: 24x7 monitoring and alerting enabled

## Maintenance

- **Updates**: Test all updates in non-production first
- **Backups**: Verify backup integrity regularly
- **Monitoring**: Monitor cluster health and performance metrics
- **Scaling**: Adjust node group sizes based on production load

## Troubleshooting

Common issues and solutions:

1. **VPC/Subnet Issues**: Verify subnet configurations and routing
2. **IAM Permissions**: Ensure production AWS profile has necessary permissions
3. **Domain Issues**: Verify Route53 configuration for production domain
4. **Resource Limits**: Check AWS service limits for production account

## Support

For production issues, contact the DevOps team immediately.
