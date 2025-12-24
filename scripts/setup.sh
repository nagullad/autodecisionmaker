#!/bin/bash
# Quick setup script for GitHub Actions deployment

set -e

echo "?? AutoDecisionMaker - AWS ECS Deployment Setup"
echo "=============================================="
echo ""

# Check prerequisites
echo "? Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "? Terraform not found. Please install from https://www.terraform.io/downloads"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "? AWS CLI not found. Please install from https://aws.amazon.com/cli/"
    exit 1
fi

echo "? Prerequisites OK"
echo ""

# Check AWS credentials
echo "?? Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "? AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}

echo "? AWS Account: $AWS_ACCOUNT_ID"
echo "? AWS Region: $AWS_REGION"
echo ""

# Prepare Terraform
echo "?? Preparing Terraform..."

if [ ! -f terraform/terraform.tfvars ]; then
    echo "??  terraform.tfvars not found. Creating from template..."
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    echo "??  Please edit terraform/terraform.tfvars and update values"
    exit 1
fi

echo "? terraform.tfvars exists"
echo ""

# Initialize Terraform
echo "?? Initializing Terraform..."
cd terraform
terraform init
terraform fmt -recursive
terraform validate

echo ""
echo "? Terraform initialized successfully"
echo ""

# Plan
echo "?? Creating Terraform plan..."
terraform plan -out=tfplan

echo ""
echo "? Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review the plan above"
echo "2. Run: terraform apply tfplan"
echo "3. Or push to GitHub main branch to trigger GitHub Actions"
echo ""
