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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Production-specific S3 backend configuration
  backend "s3" {

    bucket         = "eks-tf-state-prod-us-east-1"                    # S3 bucket for state files
    key            = "eks/eks-frontend-prod/eks-cluster.tfstate" # Production state file path
    region         = "us-east-1"                                 # AWS region
    dynamodb_table = "terraform-state-lock"                      # State locking table
    encrypt        = true                                        # State encryption enabled
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  }
}
