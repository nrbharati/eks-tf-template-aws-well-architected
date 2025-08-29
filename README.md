# EKS Terraform Template

This repository contains Terraform configurations for deploying a production-ready EKS cluster on AWS with comprehensive monitoring, security, and scalability features.

## Quick Start

1. **Select Terraform Workspace**
   ```bash
   - terraform workspace select eks-frontend-np
   ```

## commands

- rm -rf .terraform
- terraform init
   - terraform workspace select eks-frontend-np
- terraform apply
- terraform destroy



## Version upgrades:

## Cluster and core addons upgrades:
https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html


## karpenter:
https://karpenter.sh/docs/upgrading/compatibility/

### Karpenter Tag Requirements
Karpenter requires specific tags on AWS resources to function properly:

1. Security Groups:
   - Tag the EKS cluster's security group with:
     ```
     Key: karpenter.sh/discovery
     Value: true
     ```
   - This security group is used for nodes provisioned by Karpenter
   - You can find the cluster's security group using:
     ```bash
     aws eks describe-cluster --name <cluster-name> --query 'cluster.resourcesVpcConfig.securityGroupIds'
     ```

2. Subnets:
   - Tag the subnets where Karpenter should provision nodes with:
     ```
     Key: karpenter.sh/discovery
     Value: true
     ```
   - These subnets must be in the VPC where the EKS cluster is running
   - The subnets must be in the availability zones specified in the Karpenter provisioner configuration

Note: If Karpenter is not provisioning nodes, verify these tags are correctly applied to both the security group and subnets.

## ami id:
- https://github.com/awslabs/amazon-eks-ami/releases
- https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html

## alb-controller:
- helm repo add eks https://aws.github.io/eks-charts
- helm search repo eks/aws-load-balancer-controller --versions
- https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller#prerequisites


## external-dns:
- helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
- helm search repo external-dns/external-dns --versions
- https://github.com/kubernetes-sigs/external-dns?tab=readme-ov-file#kubernetes-version-compatibility


## Prometheus:
- helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
- helm search repo prometheus-community/kube-prometheus-stack --versions
- https://github.com/prometheus-operator/kube-prometheus#compatibility

## metricsserver:
- helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
- helm search repo metrics-server --versions
- https://github.com/kubernetes-sigs/metrics-server?tab=readme-ov-file#compatibility-matrix

## vpa:
- helm repo add fairwinds-stable https://charts.fairwinds.com/stable
- helm search repo fairwinds-stable/vpa --versions

## fluentbit:
- helm repo add fluent https://fluent.github.io/helm-charts
- helm search repo fluent --versions