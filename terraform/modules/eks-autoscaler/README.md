# EKS Auto Mode Module

This module provides AWS EKS Cluster Autoscaler functionality for automatic node scaling in EKS clusters.

## Features

- **Automatic Node Scaling**: Scales EKS node groups up and down based on pod resource requirements
- **IAM Integration**: Uses OIDC provider for secure service account authentication
- **Configurable Scaling**: Customizable scaling parameters and thresholds
- **Helm Deployment**: Uses official Cluster Autoscaler Helm chart
- **RBAC Ready**: Includes all necessary Kubernetes RBAC resources

## How It Works

Cluster Autoscaler monitors the cluster for pods that cannot be scheduled due to insufficient resources. When it detects such pods, it automatically scales up the appropriate node group. Similarly, it scales down nodes when they are underutilized.

## Usage

```hcl
module "eks_autoscaler" {
  source = "./modules/eks-autoscaler"
  
  enable_autoscaler = true
  cluster_name      = "my-eks-cluster"
  aws_region        = "us-east-1"
  
  openid_connect_provider_arn = module.eks.oidc_provider_arn
  openid_connect_provider_url = module.eks.cluster_oidc_issuer_url
  
  # Scaling configuration
  scale_down_enabled = true
  scale_down_delay_after_add = "10m"
  scale_down_unneeded = "10m"
  
  tags = {
    Environment = "production"
    Project     = "eks-autoscaling"
  }
}
```

## Requirements

- EKS cluster with OIDC provider enabled
- Node groups configured with autoscaling enabled
- Helm provider configured

## Node Group Configuration

Your EKS node groups must have autoscaling enabled:

```hcl
resource "aws_eks_node_group" "example" {
  # ... other configuration ...
  
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 10  # This enables autoscaling
  }
}
```

## Scaling Parameters

- **scale_down_enabled**: Enable/disable scale down
- **scale_down_delay_after_add**: Wait time after scale up before scale down evaluation
- **scale_down_unneeded**: Time before unneeded node is eligible for removal
- **scan_interval**: How often to check for scaling needs
- **scale_down_utilization_threshold**: Node utilization threshold for scale down

## Security

- Uses OIDC provider for secure authentication
- Minimal IAM permissions following least privilege principle
- RBAC resources properly configured for security

## Monitoring

Monitor the autoscaler with:

```bash
# Check autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Check autoscaler status
kubectl get configmap -n kube-system cluster-autoscaler-status -o yaml

# Check node scaling events
kubectl get events --field-selector reason=TriggeredScaleUp
```

## Troubleshooting

Common issues and solutions:

1. **Nodes not scaling up**: Check IAM permissions and OIDC provider
2. **Nodes not scaling down**: Verify scale-down parameters and pod placement
3. **Autoscaler not starting**: Check RBAC resources and service account
