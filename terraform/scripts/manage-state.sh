#!/bin/bash

# Terraform State Management Script
# This script helps prevent and resolve state lock issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Terraform is running
check_terraform_running() {
    if ps aux | grep -E "(terraform apply|terraform plan|terraform destroy|terraform init)" | grep -v grep > /dev/null; then
        print_warning "Terraform operation is already running!"
        ps aux | grep -E "(terraform apply|terraform plan|terraform destroy|terraform init)" | grep -v grep
        return 1
    fi
    return 0
}

# Function to check state lock
check_state_lock() {
    print_status "Checking for state locks..."
    
    # Check S3 backend for locks
    if aws dynamodb describe-table --table-name terraform-state-lock --region us-east-1 > /dev/null 2>&1; then
        print_status "Checking DynamoDB lock table..."
        aws dynamodb scan --table-name terraform-state-lock --region us-east-1 --query "Items[?contains(Info.S, 'eks-frontend-np')]" --output table
    else
        print_warning "DynamoDB lock table not found or accessible"
    fi
}

# Function to force unlock state
force_unlock() {
    local lock_id="$1"
    
    if [ -z "$lock_id" ]; then
        print_error "Lock ID is required. Usage: $0 unlock <lock_id>"
        exit 1
    fi
    
    print_warning "Force unlocking state with ID: $lock_id"
    terraform force-unlock "$lock_id"
    print_success "State unlocked successfully"
}

# Function to clean up state
clean_state() {
    print_status "Cleaning up Terraform state..."
    
    # Remove .terraform directory
    if [ -d ".terraform" ]; then
        print_status "Removing .terraform directory..."
        rm -rf .terraform
        print_success ".terraform directory removed"
    fi
    
    # Remove .terraform.lock.hcl
    if [ -f ".terraform.lock.hcl" ]; then
        print_status "Removing .terraform.lock.hcl..."
        rm -f .terraform.lock.hcl
        print_success ".terraform.lock.hcl removed"
    fi
    
    print_success "State cleanup completed"
}

# Function to reinitialize Terraform
reinit() {
    print_status "Reinitializing Terraform..."
    terraform init -reconfigure
    print_success "Terraform reinitialized"
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  check     - Check for state locks and running processes"
    echo "  unlock    - Force unlock state with given lock ID"
    echo "  clean     - Clean up local Terraform state files"
    echo "  reinit    - Reinitialize Terraform with reconfigure"
    echo "  plan      - Run terraform plan with safety checks"
    echo "  apply     - Run terraform apply with safety checks"
    echo "  destroy   - Run terraform destroy with safety checks"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check for locks and running processes"
    echo "  $0 unlock abc123            # Force unlock with ID abc123"
    echo "  $0 plan                     # Safe plan execution"
    echo "  $0 apply                    # Safe apply execution"
}

# Function to safe plan
safe_plan() {
    check_terraform_running
    if [ $? -eq 0 ]; then
        print_status "Running terraform plan..."
        terraform plan -out=plan.out
        print_success "Plan completed and saved to plan.out"
    fi
}

# Function to safe apply
safe_apply() {
    check_terraform_running
    if [ $? -eq 0 ]; then
        if [ -f "plan.out" ]; then
            print_status "Applying saved plan..."
            terraform apply plan.out
            print_success "Apply completed successfully"
        else
            print_error "No plan.out file found. Run 'terraform plan' first or use '$0 plan'"
            exit 1
        fi
    fi
}

# Function to safe destroy
safe_destroy() {
    check_terraform_running
    if [ $? -eq 0 ]; then
        print_warning "This will destroy all infrastructure. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_status "Running terraform destroy..."
            terraform destroy -auto-approve
            print_success "Destroy completed successfully"
        else
            print_status "Destroy cancelled"
        fi
    fi
}

# Main script logic
case "${1:-help}" in
    check)
        check_terraform_running
        check_state_lock
        ;;
    unlock)
        force_unlock "$2"
        ;;
    clean)
        clean_state
        ;;
    reinit)
        clean_state
        reinit
        ;;
    plan)
        safe_plan
        ;;
    apply)
        safe_apply
        ;;
    destroy)
        safe_destroy
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
