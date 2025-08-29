# Production EKS Cluster Deployment Guide

## Overview

This guide explains how to deploy a production EKS cluster using the existing framework while maintaining separation between environments and AWS accounts.

## Architecture Approach

### 1. Environment-Specific Directories
```
terraform/
├── environments/
│   ├── dev/          # Development environment
│   └── prod/         # Production environment (this guide)
├── modules/           # Shared modules (reused across environments)
└── scripts/           # Shared deployment scripts
```

### 2. Benefits of This Approach
- **Code Reuse**: All modules are shared between environments
- **Environment Isolation**: Each environment has its own state and configuration
- **Account Separation**: Different AWS accounts can be used for different environments
- **Version Control**: Easy to manage different versions per environment
- **Team Collaboration**: Different teams can work on different environments

## Production Environment Setup

### Step 1: Configure AWS Account

#### Option A: AWS Profile (Recommended)
```bash
# Create production profile in ~/.aws/credentials
[production]
aws_access_key_id = YOUR_PRODUCTION_ACCESS_KEY
aws_secret_access_key = YOUR_PRODUCTION_SECRET_KEY
region = us-east-1

# Update providers.tf
provider "aws" {
  region  = var.aws_region
  profile = "production"
}
```

#### Option B: Environment Variables
```bash
export AWS_ACCESS_KEY_ID=YOUR_PRODUCTION_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_PRODUCTION_SECRET_KEY
export AWS_DEFAULT_REGION=us-east-1
```

#### Option C: Cross-Account Role
```hcl
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::PRODUCTION_ACCOUNT_ID:role/YourRoleName"
    session_name = "terraform-production"
  }
}
```

### Step 2: Update Production Configuration

Edit `terraform/environments/prod/terraform.tfvars`:

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

### Step 3: Deploy Production Environment

```bash
cd terraform/environments/prod

# Use the deployment script
./deploy.sh

# Or deploy manually
terraform init
terraform plan -out=production-plan.tfplan
terraform apply production-plan.tfplan
```

## Production-Specific Features

### 1. Enhanced Security
- Private endpoint access only
- Enhanced IAM policies
- Compliance tagging
- Audit logging enabled

### 2. Robust Infrastructure
- Multiple instance types for high availability
- Larger node groups for production workloads
- Enhanced monitoring and alerting
- Backup and disaster recovery

### 3. Compliance and Governance
- Production-specific tags
- Cost center tracking
- Compliance monitoring
- Access control policies

## Managing Multiple Environments

### 1. State Management
Each environment maintains its own Terraform state:
```bash
# Development
cd terraform/environments/dev
terraform init

# Production
cd terraform/environments/prod
terraform init
```

### 2. Configuration Drift
- Use `terraform plan` regularly to detect drift
- Implement automated drift detection
- Document all manual changes

### 3. Updates and Upgrades
- Test all changes in development first
- Use blue-green deployment for major updates
- Maintain rollback procedures

## Best Practices

### 1. Security
- Use IAM roles instead of access keys
- Implement least privilege access
- Enable CloudTrail and AWS Config
- Regular security audits

### 2. Monitoring
- 24x7 monitoring and alerting
- Performance metrics tracking
- Cost monitoring and optimization
- Compliance monitoring

### 3. Backup and Recovery
- Automated backup procedures
- Disaster recovery testing
- Documentation of recovery procedures
- Regular backup validation

### 4. Change Management
- Document all changes
- Use change approval processes
- Maintain deployment logs
- Regular environment reviews

## Troubleshooting

### Common Issues

1. **VPC/Subnet Configuration**
   - Verify subnet routing tables
   - Check security group configurations
   - Validate VPC CIDR ranges

2. **IAM Permissions**
   - Ensure production AWS profile has necessary permissions
   - Check for service quotas and limits
   - Verify cross-account role configurations

3. **Domain Configuration**
   - Verify Route53 configuration
   - Check SSL certificate validity
   - Validate DNS propagation

4. **Resource Limits**
   - Check AWS service limits for production account
   - Monitor resource usage
   - Plan for scaling requirements

## Support and Maintenance

### 1. Regular Tasks
- Weekly cluster health checks
- Monthly security reviews
- Quarterly compliance audits
- Annual disaster recovery testing

### 2. Emergency Procedures
- Document emergency contacts
- Maintain escalation procedures
- Regular incident response training
- Post-incident reviews

### 3. Documentation
- Keep deployment guides updated
- Document all customizations
- Maintain runbooks for common tasks
- Regular knowledge sharing sessions

## Conclusion

This approach provides a robust, scalable way to manage multiple EKS environments while maintaining code quality and operational efficiency. The shared modules ensure consistency while environment-specific configurations allow for customization based on requirements.

For additional support or questions, refer to the DevOps team or consult the project documentation.
