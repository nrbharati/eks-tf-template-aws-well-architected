#!/bin/bash

# Production EKS Cluster Deployment Script
# This script provides a safe way to deploy the production environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="production"
PLAN_FILE="production-plan.tfplan"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}=== Production EKS Cluster Deployment ===${NC}"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $(date)"
echo ""

# Safety checks
echo -e "${YELLOW}Performing safety checks...${NC}"

# Check if we're in the right directory
if [[ ! -f "main.tf" ]] || [[ ! -f "variables.tf" ]]; then
    echo -e "${RED}Error: This script must be run from the production environment directory${NC}"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not configured or credentials are invalid${NC}"
    exit 1
fi

# Check current AWS account
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "Current AWS Account: $CURRENT_ACCOUNT"

# Confirm deployment
echo ""
echo -e "${YELLOW}WARNING: You are about to deploy to PRODUCTION environment${NC}"
echo -e "${YELLOW}Current AWS Account: $CURRENT_ACCOUNT${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [[ $confirm != "yes" ]]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 0
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Initialize Terraform
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Check and manage workspace
echo -e "${GREEN}Managing Terraform workspace...${NC}"
CURRENT_WORKSPACE=$(terraform workspace show 2>/dev/null || echo "default")

if [[ "$CURRENT_WORKSPACE" != "prod" ]]; then
    echo "Current workspace: $CURRENT_WORKSPACE"
    echo "Creating/selecting production workspace..."
    
    if terraform workspace list | grep -q "prod"; then
        terraform workspace select prod
    else
        terraform workspace new prod
    fi
    
    echo "Switched to workspace: $(terraform workspace show)"
else
    echo "Already in production workspace: $CURRENT_WORKSPACE"
fi

# Format and validate
echo -e "${GREEN}Formatting Terraform code...${NC}"
terraform fmt -recursive

echo -e "${GREEN}Validating Terraform configuration...${NC}"
terraform validate

# Plan deployment
echo -e "${GREEN}Creating deployment plan...${NC}"
terraform plan -out="$PLAN_FILE"

# Show plan summary
echo ""
echo -e "${GREEN}Deployment Plan Summary:${NC}"
terraform show -no-color "$PLAN_FILE" | grep -E "(Plan:|Resource actions:|Terraform will perform the following actions:)" || true

# Final confirmation
echo ""
echo -e "${YELLOW}Review the plan above carefully${NC}"
read -p "Do you want to proceed with the deployment? (yes/no): " final_confirm

if [[ $final_confirm != "yes" ]]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 0
fi

# Deploy
echo -e "${GREEN}Deploying production environment...${NC}"
terraform apply "$PLAN_FILE"

# Save outputs
echo -e "${GREEN}Saving deployment outputs...${NC}"
terraform output > "$BACKUP_DIR/outputs.txt"

# Show final status
echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $(date)"
echo "Backup saved to: $BACKUP_DIR"
echo ""

# Show cluster info
if command -v kubectl &> /dev/null; then
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "Unknown")
    echo -e "${GREEN}Cluster Name: $CLUSTER_NAME${NC}"
    
    # Get cluster status
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}Cluster Status: Running${NC}"
        kubectl get nodes --no-headers | wc -l | xargs echo "Number of Nodes:"
    else
        echo -e "${YELLOW}Cluster Status: Not accessible (may need kubeconfig)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Production deployment completed successfully!${NC}"
