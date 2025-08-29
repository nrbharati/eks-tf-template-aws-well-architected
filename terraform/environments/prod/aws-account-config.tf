# AWS Account Configuration for Production Environment
# This file shows different ways to configure AWS accounts

# Option 1: AWS Profile (Recommended for different accounts)
# Create an AWS profile in ~/.aws/credentials:
# [production]
# aws_access_key_id = YOUR_PRODUCTION_ACCESS_KEY
# aws_secret_access_key = YOUR_PRODUCTION_SECRET_KEY
# region = us-east-1

# Then use in providers.tf:
# provider "aws" {
#   region  = var.aws_region
#   profile = "production"
# }

# Option 2: Environment Variables
# Set these environment variables before running terraform:
# export AWS_ACCESS_KEY_ID=YOUR_PRODUCTION_ACCESS_KEY
# export AWS_SECRET_ACCESS_KEY=YOUR_PRODUCTION_SECRET_KEY
# export AWS_DEFAULT_REGION=us-east-1

# Option 3: AWS SSO (Recommended for enterprise)
# Configure AWS SSO in ~/.aws/config:
# [profile production]
# sso_start_url = https://your-sso-portal.awsapps.com/start
# sso_region = us-east-1
# sso_account_id = YOUR_PRODUCTION_ACCOUNT_ID
# sso_role_name = YourRoleName
# region = us-east-1

# Option 4: Cross-Account Role Assumption
# If you need to assume a role in the production account:
# provider "aws" {
#   region = var.aws_region
#   assume_role {
#     role_arn = "arn:aws:iam::PRODUCTION_ACCOUNT_ID:role/YourRoleName"
#     session_name = "terraform-production"
#   }
# }

# Option 5: Terraform Variables (Less secure, not recommended for production)
# Add to variables.tf:
# variable "aws_access_key" {
#   description = "AWS access key for production account"
#   type        = string
#   sensitive   = true
# }
# 
# variable "aws_secret_key" {
#   description = "AWS secret key for production account"
#   type        = string
#   sensitive   = true
# }

# Then use in providers.tf:
# provider "aws" {
#   region     = var.aws_region
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
# }

# Security Best Practices:
# 1. Use IAM roles instead of access keys when possible
# 2. Implement least privilege access
# 3. Rotate credentials regularly
# 4. Use AWS Organizations for account management
# 5. Enable CloudTrail for audit logging
# 6. Use AWS Config for compliance monitoring
