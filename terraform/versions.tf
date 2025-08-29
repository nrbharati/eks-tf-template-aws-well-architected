terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  
  backend "s3" {
    bucket         = "eks-tf-state-np-us-east-1"                    # S3 bucket for state files
    key            = "eks/eks-frontend-np/eks-cluster.tfstate" # Non-production state file path
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  }
} 