#!/bin/bash
# Script to destroy AWS infrastructure and save costs

set -e

echo "??  WARNING: This will destroy ALL AWS resources"
echo "Application: autodecisionmaker"
echo ""
read -p "Are you sure? Type 'destroy' to confirm: " confirmation

if [ "$confirmation" != "destroy" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "???  Destroying infrastructure..."
echo ""

cd terraform
terraform destroy

echo ""
echo "? Infrastructure destroyed successfully!"
echo "Your AWS resources have been cleaned up."
