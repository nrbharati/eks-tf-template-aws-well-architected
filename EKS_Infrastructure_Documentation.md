# EKS Infrastructure Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Configuration Details](#configuration-details)
5. [Security](#security)
6. [Monitoring & Observability](#monitoring--observability)
7. [Auto-scaling](#auto-scaling)
8. [Networking](#networking)
9. [Backup & Recovery](#backup--recovery)
10. [Access Management](#access-management)
11. [Maintenance & Operations](#maintenance--operations)
12. [Troubleshooting](#troubleshooting)

---

## Overview

### Purpose
This document provides comprehensive documentation for the EKS (Elastic Kubernetes Service) infrastructure deployed using Terraform. The infrastructure is designed for production workloads with high availability, security, and scalability requirements.

### Environment Details
- **Environment**: Non-Production
- **AWS Region**: us-east-1
- **Cluster Name**: eks-frontend-cluster
- **Kubernetes Version**: 1.32
- **Domain**: nonprod-aws.example.com

### Key Features
- ✅ Multi-AZ deployment across 3 availability zones
- ✅ **Dual Auto-scaling Options**: Karpenter (advanced) + EKS Auto Mode (simple)
- ✅ Prometheus/Grafana monitoring stack
- ✅ AWS Load Balancer Controller for ingress management
- ✅ External DNS for automatic DNS record management
- ✅ EBS CSI Driver for persistent storage
- ✅ Fluent Bit for log aggregation
- ✅ IAM roles with least privilege access
- ✅ Security groups and network policies

---

## Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS EKS Infrastructure                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   AZ-1a     │  │   AZ-1b     │  │   AZ-1c     │         │
│  │             │  │             │  │             │         │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │         │
│  │ │ Private │ │  │ │ Private │ │  │ │ Private │ │         │
│  │ │ Subnet  │ │  │ │ Subnet  │ │  │ │ Subnet  │ │         │
│  │ │         │ │  │ │         │ │  │ │         │ │         │
│  │ │ ┌─────┐ │ │  │ │ ┌─────┐ │ │  │ │ ┌─────┐ │ │         │
│  │ │ │ EKS │ │ │  │ │ │ EKS │ │ │  │ │ │ EKS │ │ │         │
│  │ │ │Node │ │ │  │ │ │Node │ │ │  │ │ │Node │ │ │         │
│  │ │ └─────┘ │ │  │ │ └─────┘ │ │  │ │ └─────┘ │ │         │
│  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Public    │  │   Public    │  │   Public    │         │
│  │   Subnets   │  │   Subnets   │  │   Subnets   │         │
│  │  (ALB/NAT)  │  │  (ALB/NAT)  │  │  (ALB/NAT)  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Component Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    EKS Cluster                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   Control Plane │  │   Worker Nodes  │                  │
│  │   (Managed)     │  │   (Self-Managed)│                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    Add-ons                              │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │ │
│  │  │ VPC CNI │ │CoreDNS  │ │KubeProxy│ │EBS CSI  │       │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Applications                           │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │ │
│  │  │Karpenter│ │Prometheus│ │ Grafana │ │FluentBit│       │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Auto-scaling                          │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │ │
│  │  │Karpenter│ │EKS Auto │ │Cluster  │ │Metrics  │       │ │
│  │  │(Advanced│ │Mode     │ │Autoscaler│ │Server   │       │ │
│  │  │Scaling) │ │(Simple) │ │(Node)   │ │(HPA)    │       │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Infrastructure Components

### 1. EKS Cluster
**Module**: `terraform/modules/eks/`

#### Configuration Details
- **Cluster Name**: eks-frontend-cluster
- **Kubernetes Version**: 1.32
- **VPC ID**: vpc-XXXXXXXXX
- **Subnets**: 3 private subnets across AZs
- **Endpoint Access**: Both private and public access enabled
- **Logging**: API, audit, authenticator, controller manager, scheduler

#### Node Groups
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
      "karpenter.sh/capacity-type" = "on-demand"
      "node.kubernetes.io/instance-type" = "on-demand"
      "karpenter.sh/do-not-evict" = "true"
    }
  }
}
```

### 2. Karpenter Auto-scaling
**Module**: `terraform/modules/karpenter/`

#### Configuration Details
- **Version**: 0.36.0
- **Instance Types**: t3.medium, t3.large, t3.xlarge
- **Capacity Types**: on-demand, spot
- **Resource Limits**: 100 CPU, 100Gi Memory
- **Consolidation**: Enabled
- **TTL After Empty**: 300 seconds
- **TTL Until Expired**: 30 days

#### NodePool Configuration
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  limits:
    resources:
      cpu: "1000"
      memory: "1000Gi"
  requirements:
  - key: karpenter.k8s.aws/instance-category
    operator: In
    values: ["c", "m", "r"]
  - key: karpenter.k8s.aws/instance-generation
    operator: Gt
    values: ["2"]
  - key: kubernetes.io/arch
    operator: In
    values: ["amd64"]
  - key: kubernetes.io/os
    operator: In
    values: ["linux"]
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["on-demand", "spot"]
```

### 3. EKS Auto Mode (Cluster Autoscaler)
**Module**: `terraform/modules/eks-autoscaler/`

#### Configuration Details
- **Version**: 9.35.0 (Helm chart)
- **Auto-scaling**: Node group level scaling
- **AWS Integration**: Native Auto Scaling Group integration
- **Scaling Strategy**: Least-waste expander
- **Protection**: System pod and local storage protection

#### Autoscaler Configuration
```hcl
autoscaler_config = {
  scale_down_enabled = true
  scale_down_delay_after_add = "10m"
  scale_down_unneeded = "10m"
  max_node_provision_time = "15m"
  scan_interval = "10s"
  scale_down_utilization_threshold = "0.5"
  skip_nodes_with_local_storage = true
  skip_nodes_with_system_pods = true
  expander = "least-waste"
  balance_similar_node_groups = true
  max_total_unready_percentage = "45"
  ok_total_unready_count = "3"
}
```

#### Node Group Configuration
```hcl
node_groups = {
  main = {
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 3
      min_size     = 2
      max_size     = 8
    }
    labels = {
      "role" = "general"
    }
  }
}
```

#### Key Features
- **Automatic Scaling**: Scales up/down based on pod demand
- **Cooldown Periods**: 10-minute cooldown after scale-up before scale-down
- **Resource Thresholds**: 50% utilization threshold for scale-down
- **System Protection**: Protects nodes with system pods or local storage
- **AWS Native**: Direct integration with Auto Scaling Groups
- **Fast Response**: 10-second scan interval for quick scaling decisions

#### Scaling Behavior
- **Scale Up**: Triggers when pods are pending due to insufficient resources
- **Scale Down**: Removes nodes after 10 minutes of being "unneeded"
- **Protection**: Nodes with system pods or local storage are protected
- **Balancing**: Balances similar node groups for optimal resource distribution

### 4. Monitoring Stack
**Module**: `terraform/modules/monitoring/`

#### Prometheus Configuration
- **Chart Version**: 75.0.0
- **Namespace**: monitoring
- **Storage**: Persistent volumes via EBS CSI
- **Retention**: 15 days
- **Scrape Interval**: 30s

#### Grafana Configuration
- **Admin User**: admin
- **Admin Password**: eksadmin@dev0ps
- **Ingress**: Internal ALB
- **Hostname**: grafana-eks-frontend-cluster.nonprod-aws.example.com
- **Access URL**: http://grafana-eks-frontend-cluster.nonprod-aws.example.com

#### Fluent Bit Configuration
- **Chart Version**: 0.46.6
- **CloudWatch Integration**: Enabled
- **Log Group**: /aws/eks/eks-frontend-cluster/fluentbit
- **Retention**: 30 days
- **Node Selector**: role=general

### 5. Add-ons
**Module**: `terraform/modules/addons/`

#### Core Add-ons
- **VPC CNI**: v1.19.6-eksbuild.1
- **CoreDNS**: v1.11.4-eksbuild.14
- **Kube Proxy**: v1.32.3-eksbuild.7
- **EBS CSI Driver**: Latest version
- **Metrics Server**: 3.12.2

#### AWS Load Balancer Controller
- **Chart Version**: 1.13.2
- **Ingress Class**: alb
- **Scheme**: Internal
- **Target Type**: IP

#### External DNS
- **Chart Version**: 1.16.1
- **Provider**: AWS Route53
- **Domain Filter**: nonprod-aws.example.com
- **Policy**: Sync
- **CNAME Preference**: Enabled

### 6. Security
**Module**: `terraform/modules/security/`

#### Security Groups
- **Cluster Security Group**: EKS control plane access
- **Node Security Group**: Worker node communication
- **Ingress Rules**: HTTPS (443), HTTP (80)
- **Egress Rules**: All traffic (0.0.0.0/0)

#### IAM Roles and Policies
- **Cluster Role**: AmazonEKSClusterPolicy, AmazonEKSVPCResourceController
- **Node Role**: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly
- **Karpenter Role**: Custom EC2 policy for node provisioning
- **Service Accounts**: IRSA (IAM Roles for Service Accounts) enabled

### 7. Networking
**Module**: `terraform/modules/network/`

#### VPC Configuration
- **VPC ID**: vpc-XXXXXXXXX (Existing)
- **Private Subnets**: 3 subnets across AZs
- **Public Subnets**: 3 subnets across AZs
- **NAT Gateways**: 1 per AZ
- **Internet Gateway**: 1 per VPC

#### DNS Configuration
- **Domain**: nonprod-aws.example.com
- **External DNS**: Automatic record creation
- **CNAME Records**: Preferred over A records for ALBs

---

## Configuration Details

### Terraform Variables
Key configuration variables in `terraform.tfvars`:

```hcl
# Cluster Configuration
cluster_name = "eks-frontend-cluster"
cluster_version = "1.32"
aws_region = "us-east-1"

# VPC and Subnet Configuration
vpc_id = "vpc-XXXXXXXXX"
private_subnet_ids = ["subnet-XXXXXXXXX","subnet-XXXXXXXXX","subnet-XXXXXXXXX"]
public_subnet_ids = ["subnet-XXXXXXXXX","subnet-XXXXXXXXX","subnet-XXXXXXXXX"]

# Monitoring Configuration
enable_monitoring = true
grafana_admin_user = "admin"
grafana_admin_password = "eksadmin@dev0ps"
domain_name = "nonprod-aws.example.com"

# Karpenter Configuration
karpenter_instance_types = ["t3.medium", "t3.large", "t3.xlarge"]
karpenter_limits = {
  cpu    = "100"
  memory = "100Gi"
}
```

### Module Dependencies
```
main.tf
├── module.security
├── module.eks (depends_on: module.security)
├── module.addons (depends_on: module.eks)
├── module.monitoring (depends_on: [module.eks, module.addons])
├── module.rbac (depends_on: module.eks)
├── module.kubernetes (depends_on: [module.eks, module.addons])
├── module.karpenter (depends_on: [module.eks, module.addons])
├── module.backup (depends_on: module.eks)
└── module.vpc
```

---

## Security

### Network Security
- **Private Subnets**: Worker nodes deployed in private subnets
- **Security Groups**: Least privilege access rules
- **NAT Gateways**: Outbound internet access through NAT
- **VPC Endpoints**: AWS service access without internet

### IAM Security
- **IRSA**: IAM Roles for Service Accounts enabled
- **Least Privilege**: Minimal required permissions
- **OIDC Provider**: AWS OIDC provider for service accounts
- **Role-based Access**: Different roles for different components

### Pod Security
- **Security Contexts**: Non-root user execution
- **Network Policies**: Pod-to-pod communication control
- **Resource Limits**: CPU and memory limits enforced
- **Secrets Management**: Kubernetes secrets for sensitive data

### Encryption
- **Data at Rest**: EBS volumes encrypted
- **Data in Transit**: TLS encryption for all communications
- **Secrets**: Kubernetes secrets encrypted

---

## Monitoring & Observability

### Metrics Collection
- **Prometheus**: Metrics collection and storage
- **Node Exporter**: Node-level metrics
- **Kube State Metrics**: Kubernetes object metrics
- **Custom Metrics**: Application-specific metrics

### Logging
- **Fluent Bit**: Log collection and forwarding
- **CloudWatch Logs**: Centralized log storage
- **Log Retention**: 30 days
- **Log Streams**: Per-node log streams

### Visualization
- **Grafana**: Dashboard and visualization
- **Pre-built Dashboards**: Kubernetes, Node, Pod dashboards
- **Custom Dashboards**: Application-specific dashboards
- **Alerting**: Prometheus alerting rules

### Alerting
- **Prometheus Alertmanager**: Alert routing and notification
- **Slack Integration**: Team notifications
- **Email Alerts**: Critical system alerts
- **PagerDuty**: On-call notifications

---

## Auto-scaling

### Auto-scaling Options
The infrastructure supports two auto-scaling solutions:

1. **Karpenter** (Advanced, feature-rich auto-scaling)
2. **EKS Auto Mode** (Simple, AWS-native auto-scaling)

### Karpenter Configuration
- **Provisioner**: Default provisioner for all workloads
- **Instance Selection**: Based on resource requirements
- **Spot Instances**: Cost optimization with spot instances
- **Consolidation**: Automatic node consolidation

### EKS Auto Mode Configuration
- **Node Group Scaling**: Automatic scaling of EKS node groups
- **AWS Integration**: Native Auto Scaling Group integration
- **Cooldown Periods**: 10-minute cooldown after scale-up
- **Resource Thresholds**: 50% utilization for scale-down decisions

### Scaling Policies
- **CPU-based Scaling**: Scale based on CPU utilization
- **Memory-based Scaling**: Scale based on memory usage
- **Custom Metrics**: Application-specific scaling
- **Predictive Scaling**: ML-based scaling predictions (Karpenter)

### Node Management
- **TTL Policies**: Automatic node termination (Karpenter)
- **Eviction Policies**: Pod eviction strategies
- **Node Labels**: Automatic labeling for workload placement
- **Taints and Tolerations**: Workload isolation
- **System Protection**: Protection of nodes with system pods (EKS Auto Mode)

### Choosing Between Auto-scaling Solutions

#### When to Use Karpenter
- **Advanced Requirements**: Need pod-level scaling, dynamic instance selection
- **Cost Optimization**: Want to leverage spot instances and advanced consolidation
- **Flexibility**: Need custom scaling policies and advanced features
- **Complex Workloads**: Mixed workloads with different resource requirements

#### When to Use EKS Auto Mode
- **Simple Scaling**: Basic node group level scaling is sufficient
- **AWS Native**: Prefer AWS-managed solutions with minimal complexity
- **Predictable Costs**: Want fixed instance types and predictable scaling
- **Easy Maintenance**: Simpler configuration and easier troubleshooting

#### Configuration Toggle
```hcl
# Enable/Disable Karpenter
enable_karpenter = false

# Enable/Disable EKS Cluster Autoscaler
enable_eks_autoscaler = true
```

**Note**: Only one auto-scaling solution should be enabled at a time to avoid conflicts.

---

## Networking

### Load Balancing
- **AWS Load Balancer Controller**: Kubernetes-native load balancing
- **Application Load Balancer**: Layer 7 load balancing
- **Network Load Balancer**: Layer 4 load balancing
- **Target Groups**: Automatic target group management

### Ingress Management
- **Ingress Resources**: Kubernetes ingress objects
- **ALB Integration**: Automatic ALB creation
- **SSL Termination**: TLS certificate management
- **Path-based Routing**: URL path routing

### DNS Management
- **External DNS**: Automatic DNS record creation
- **Route53 Integration**: AWS DNS service
- **CNAME Records**: Load balancer DNS records
- **Health Checks**: DNS health monitoring

---

## Backup & Recovery

### EBS Backups
- **Snapshot Policy**: Automated EBS snapshots
- **Retention**: 7 days retention
- **Cross-Region**: Backup replication
- **Encryption**: Encrypted backups

### Cluster State
- **Terraform State**: Infrastructure state backup
- **S3 Backend**: Remote state storage
- **State Locking**: Concurrent access protection
- **Versioning**: State file versioning

### Disaster Recovery
- **Multi-AZ**: High availability across AZs
- **Cross-Region**: Disaster recovery planning
- **Backup Testing**: Regular recovery testing
- **RTO/RPO**: Recovery time and point objectives

---

## Access Management

### Cluster Access
- **EKS Access Entry**: AWS EKS access management
- **Admin User**: YOUR_USER_NAME (cluster admin)
- **RBAC**: Role-based access control
- **Service Accounts**: Application access

### AWS Access
- **IAM Users**: Individual user access
- **IAM Roles**: Cross-account access
- **SSO Integration**: Single sign-on
- **MFA**: Multi-factor authentication

### Application Access
- **Ingress**: External application access
- **Service Mesh**: Internal service communication
- **API Gateway**: API access management
- **Authentication**: OAuth2/OIDC integration

---

## Maintenance & Operations

### Updates and Upgrades
- **EKS Version**: Kubernetes version upgrades
- **Add-on Updates**: EKS add-on version updates
- **Security Patches**: Regular security updates
- **Dependency Updates**: Third-party dependency updates

### Monitoring and Alerting
- **Health Checks**: Regular health monitoring
- **Performance Monitoring**: Resource utilization tracking
- **Cost Monitoring**: AWS cost tracking
- **Compliance Monitoring**: Security compliance checks

### Troubleshooting
- **Log Analysis**: Centralized log analysis
- **Metrics Analysis**: Performance metrics analysis
- **Network Diagnostics**: Network connectivity testing
- **Security Audits**: Regular security assessments

### Capacity Planning
- **Resource Forecasting**: Future resource needs
- **Cost Optimization**: AWS cost optimization
- **Performance Tuning**: System performance optimization
- **Scaling Planning**: Auto-scaling configuration tuning

---

## Troubleshooting

### Common Issues

#### 1. Karpenter Node Provisioning Issues
**Symptoms**: Pods stuck in pending state
**Causes**: 
- IAM permissions issues
- Security group configuration
- VPC/subnet configuration
- Instance type availability

**Solutions**:
```bash
# Check Karpenter logs
kubectl logs -n karpenter deployment/karpenter

# Check node pool status
kubectl get nodepool

# Check EC2 node class
kubectl get ec2nodeclass

# Verify IAM roles
aws iam get-role --role-name eks-frontend-cluster-karpenter
```

#### 2. EKS Autoscaler Issues
**Symptoms**: Nodes not scaling up/down, autoscaler pod in CrashLoopBackOff
**Causes**: 
- Invalid command line arguments
- IAM permissions issues
- Auto Scaling Group configuration problems
- Resource constraints

**Solutions**:
```bash
# Check autoscaler pod status
kubectl get pods -n kube-system | grep autoscaler

# Check autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler-aws-cluster-autoscaler

# Verify Auto Scaling Group
aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(Tags[?Key=='eks:cluster-name'].Value, 'eks-frontend-cluster')]"

# Check node group scaling
kubectl get nodes
aws eks describe-nodegroup --cluster-name eks-frontend-cluster --nodegroup-name main
```

#### 3. DNS Resolution Issues
**Symptoms**: Services not accessible via domain names
**Causes**:
- External DNS not working
- Route53 configuration issues
- Ingress configuration problems

**Solutions**:
```bash
# Check external-dns logs
kubectl logs -n kube-system deployment/external-dns

# Verify DNS records
nslookup grafana-eks-frontend-cluster.nonprod-aws.example.com

# Check ingress status
kubectl get ingress -A
```

#### 4. Monitoring Stack Issues
**Symptoms**: Grafana not accessible, metrics missing
**Causes**:
- Prometheus configuration issues
- Storage problems
- Network connectivity issues

**Solutions**:
```bash
# Check Prometheus status
kubectl get pods -n monitoring

# Check Grafana logs
kubectl logs -n monitoring deployment/kube-prometheus-stack-grafana

# Verify persistent volumes
kubectl get pvc -n monitoring
```

#### 5. Node Group Issues
**Symptoms**: Nodes not joining cluster
**Causes**:
- IAM role issues
- Security group configuration
- Bootstrap script problems

**Solutions**:
```bash
# Check node status
kubectl get nodes

# Check node group status
aws eks describe-nodegroup --cluster-name eks-frontend-cluster --nodegroup-name main

# Check node logs
kubectl logs -n kube-system daemonset/aws-node
```

### Useful Commands

#### Cluster Information
```bash
# Get cluster info
kubectl cluster-info

# Get node information
kubectl get nodes -o wide

# Get pod information
kubectl get pods -A

# Get service information
kubectl get svc -A
```

#### Logs and Debugging
```bash
# Get pod logs
kubectl logs -n <namespace> <pod-name>

# Describe resources
kubectl describe pod -n <namespace> <pod-name>

# Get events
kubectl get events -A --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods -A
```

#### AWS Resources
```bash
# Check EKS cluster
aws eks describe-cluster --name eks-frontend-cluster

# Check node groups
aws eks list-nodegroups --cluster-name eks-frontend-cluster

# Check load balancers
aws elbv2 describe-load-balancers

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>
```

### Performance Optimization

#### Resource Optimization
- **Node Sizing**: Right-size nodes for workloads
- **Pod Resource Limits**: Set appropriate resource limits
- **Horizontal Pod Autoscaling**: Configure HPA for applications
- **Vertical Pod Autoscaling**: Configure VPA for resource optimization

#### Cost Optimization
- **Spot Instances**: Use spot instances for non-critical workloads
- **Instance Types**: Choose cost-effective instance types
- **Resource Scheduling**: Optimize pod placement
- **Idle Resource Cleanup**: Remove unused resources

---

## Conclusion

This EKS infrastructure provides a robust, scalable, and secure foundation for running containerized applications. The combination of Karpenter for auto-scaling, comprehensive monitoring, and security best practices ensures high availability and operational excellence.

### Key Benefits
- **High Availability**: Multi-AZ deployment with auto-scaling
- **Flexible Auto-scaling**: Choose between Karpenter (advanced) and EKS Auto Mode (simple)
- **Cost Optimization**: Spot instance usage with Karpenter, predictable scaling with EKS Auto Mode
- **Security**: IAM roles, security groups, and encryption
- **Observability**: Comprehensive monitoring and logging
- **Automation**: Infrastructure as Code with Terraform
- **Scalability**: Automatic scaling based on demand

### Next Steps
1. **Application Deployment**: Deploy applications using the provided infrastructure
2. **Custom Dashboards**: Create application-specific Grafana dashboards
3. **Alerting Rules**: Configure custom alerting rules for applications
4. **Security Hardening**: Implement additional security measures as needed
5. **Performance Tuning**: Optimize based on actual usage patterns

---

## Appendix

### Useful Links
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Karpenter Documentation](https://karpenter.sh/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)

### Contact Information
- **DevOps Team**: DevOps
- **Primary Contact**: Nikhil Bharati
- **Environment**: non-prod
- **Project**: eks-framework

### Version History
- **v1.0**: Initial documentation
- **v1.1**: Added troubleshooting section
- **v1.2**: Updated with current configuration
- **v1.3**: Added EKS Auto Mode (Cluster Autoscaler) documentation and configuration 

# SSO Roles for EKS Access
sso_roles = {
  global_admin   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_XXXXXXXXX"
  administrator  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PowerUserAccess_XXXXXXXXX"
  developer      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_DeveloperAccess_XXXXXXXXX"
  viewer         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_XXXXXXXXX"
} 


