provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

provider "null" {}

# The Kubernetes, Helm, and Kubectl providers will be configured in kubernetes_providers.tf
# after the EKS cluster is created

# The Helm provider configuration has been removed as per the instructions 