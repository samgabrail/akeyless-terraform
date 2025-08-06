#!/bin/bash

# Cleanup script for Akeyless Terraform Demo
# This script destroys the infrastructure created in both parts of the demo

set -e

echo "🧹 Akeyless Terraform Demo Cleanup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the demo directory
if [[ ! -d "part1-akeyless-setup" || ! -d "part2-infrastructure-deployment" ]]; then
    print_error "Please run this script from the demo directory"
    exit 1
fi

print_warning "This will destroy ALL resources created by the demo!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cleanup cancelled"
    exit 0
fi

# Part 2: Destroy infrastructure deployment first
print_status "Destroying Part 2: Infrastructure Deployment..."
cd part2-infrastructure-deployment

if [[ -f "terraform.tfstate" ]]; then
    terraform destroy -auto-approve
    if [[ $? -eq 0 ]]; then
        print_status "Part 2 infrastructure destroyed successfully"
    else
        print_error "Failed to destroy Part 2 infrastructure"
        exit 1
    fi
else
    print_warning "No terraform.tfstate found in part2-infrastructure-deployment"
fi

cd ..

# Part 1: Destroy Akeyless setup
print_status "Destroying Part 1: Akeyless Setup..."
cd part1-akeyless-setup

if [[ -f "terraform.tfstate" ]]; then
    terraform destroy -auto-approve
    if [[ $? -eq 0 ]]; then
        print_status "Part 1 Akeyless setup destroyed successfully"
    else
        print_error "Failed to destroy Part 1 Akeyless setup"
        exit 1
    fi
else
    print_warning "No terraform.tfstate found in part1-akeyless-setup"
fi

cd ..

print_status "Cleanup completed successfully!"
echo
print_warning "Note: Dynamic AWS credentials from Akeyless will expire automatically"
print_warning "Static secrets in Akeyless have been removed"
print_status "Demo environment is now clean"