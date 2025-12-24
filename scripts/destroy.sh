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
echo "???  Preparing for destruction..."
echo ""

cd terraform

# Cleanup unmanaged ALB listener rules before destroy
APP_NAME="autodecisionmaker"
AWS_REGION="us-east-1"
ALB_NAME="${APP_NAME}-alb"
TG_NAME="${APP_NAME}-tg"

echo "Checking for ALB: $ALB_NAME"
ALB_ARN=$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$AWS_REGION" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || true)
if [ -n "$ALB_ARN" ] && [ "$ALB_ARN" != "None" ]; then
  echo "ALB exists: $ALB_ARN"
  TG_ARN=$(aws elbv2 describe-target-groups --names "$TG_NAME" --region "$AWS_REGION" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || true)
  if [ -n "$TG_ARN" ] && [ "$TG_ARN" != "None" ]; then
    echo "Target group exists: $TG_ARN"
    LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn "$ALB_ARN" --region "$AWS_REGION" --query 'Listeners[].ListenerArn' --output text 2>/dev/null || true)
    for LISTENER_ARN in $LISTENER_ARNS; do
      echo "Checking rules on listener $LISTENER_ARN"
      RULES=$(aws elbv2 describe-rules --listener-arn "$LISTENER_ARN" --region "$AWS_REGION" --query 'Rules[].RuleArn' --output text 2>/dev/null || true)
      for R in $RULES; do
        TARGET_ARNS=$(aws elbv2 describe-rules --rule-arns "$R" --region "$AWS_REGION" --query 'Rules[0].Actions[?TargetGroupArn!=null].TargetGroupArn' --output text 2>/dev/null || true)
        if echo "$TARGET_ARNS" | grep -q "$TG_ARN" ; then
          IS_DEFAULT=$(aws elbv2 describe-rules --rule-arns "$R" --region "$AWS_REGION" --query 'Rules[0].IsDefault' --output text 2>/dev/null || true)
          if [ "$IS_DEFAULT" = "false" ] && ! terraform state list | grep -q '^aws_lb_listener_rule\.' ; then
            echo "Deleting unmanaged non-default rule $R"
            aws elbv2 delete-rule --rule-arn "$R" --region "$AWS_REGION" || true
          else
            echo "Skipping rule $R (default, managed, or unknown)"
          fi
        fi
      done
    done
  fi
fi

echo ""
echo "???  Destroying infrastructure..."
echo ""

terraform destroy

echo ""
echo "? Infrastructure destroyed successfully!"
echo "Your AWS resources have been cleaned up."
