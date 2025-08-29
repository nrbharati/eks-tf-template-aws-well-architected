# Network Module

This module manages the networking infrastructure for the EKS cluster, including VPC, subnets, and related resources.

## Overview

The network module is responsible for:
- Creating and managing VPC
- Configuring public and private subnets
- Setting up NAT gateways
- Managing route tables
- Configuring security groups
- Setting up VPC endpoints
- Managing network ACLs

## Features

1. **VPC Configuration**
   - VPC creation and management
   - CIDR block allocation
   - DNS settings
   - VPC endpoints

2. **Subnet Management**
   - Public subnets
   - Private subnets
   - Database subnets
   - Subnet tagging

3. **Network Security**
   - Security groups
   - Network ACLs
   - Route tables
   - NAT gateways

4. **VPC Endpoints**
   - S3 endpoint
   - ECR endpoints
   - CloudWatch endpoints
   - Other AWS services

## Usage

```hcl
module "network" {
  source = "./modules/network"

  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | n/a | yes |
| azs | List of availability zones | `list(string)` | n/a | yes |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | n/a | yes |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | n/a | yes |
| enable_nat_gateway | Whether to create NAT gateways | `bool` | `true` | no |
| single_nat_gateway | Whether to use a single NAT gateway | `bool` | `false` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| nat_gateway_ids | List of NAT gateway IDs |
| vpc_cidr_block | CIDR block of the VPC |

## VPC Configuration

The VPC can be configured with the following options:

```hcl
vpc_config = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_classiclink             = false
  enable_classiclink_dns_support = false
  
  enable_ipv6 = false
}
```

## Subnet Configuration

Subnets can be configured with the following options:

```hcl
subnet_config = {
  public = {
    cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    azs   = ["us-west-2a", "us-west-2b", "us-west-2c"]
    tags = {
      "kubernetes.io/role/elb" = "1"
    }
  }
  
  private = {
    cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    azs   = ["us-west-2a", "us-west-2b", "us-west-2c"]
    tags = {
      "kubernetes.io/role/internal-elb" = "1"
    }
  }
}
```

## Security Features

1. **Security Groups**
   - Cluster security group
   - Node security group
   - Load balancer security group

2. **Network ACLs**
   - Public subnet ACLs
   - Private subnet ACLs
   - Database subnet ACLs

3. **Route Tables**
   - Public route table
   - Private route tables
   - Database route tables

## Best Practices

1. **High Availability**
   - Multi-AZ deployment
   - Redundant NAT gateways
   - Route table redundancy

2. **Security**
   - Network isolation
   - Security group rules
   - NACL configuration

3. **Cost Optimization**
   - NAT gateway placement
   - Subnet sizing
   - Resource tagging

## Maintenance

1. **Resource Management**
   - Subnet management
   - Route table updates
   - Security group updates

2. **Monitoring**
   - VPC flow logs
   - Network monitoring
   - Security monitoring

3. **Backup and Recovery**
   - Configuration backup
   - Route table backup
   - Security group backup

## Troubleshooting

1. **Connectivity Issues**
   - Route table problems
   - Security group issues
   - NACL configuration

2. **NAT Gateway Issues**
   - Gateway configuration
   - Route table problems
   - Cost optimization

3. **VPC Endpoint Issues**
   - Endpoint configuration
   - Security group rules
   - Route table updates 