# Production Environment AWS Provider Configuration
# This file can be configured for different AWS accounts using AWS profiles or credentials

# AWS Provider Configuration
# Option 1: Use AWS Profile (recommended for different accounts)
provider "aws" {
  region = var.aws_region
  # profile = "your-profile-name" # Uncomment and set to your AWS profile name if needed

  default_tags {
    tags = var.default_tags
  }
}

# Option 2: Use AWS Credentials directly (alternative approach)
# provider "aws" {
#   region     = var.aws_region
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
#   
#   default_tags {
#     tags = var.default_tags
#   }
# }

# Other providers
provider "null" {}
provider "random" {}

# The Kubernetes, Helm, and Kubectl providers will be configured in kubernetes_providers.tf
# after the EKS cluster is created
