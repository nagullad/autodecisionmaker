#!/bin/bash
# Script to check deployment status

echo "?? Checking AutoDecisionMaker Deployment Status"
echo "=============================================="
echo ""

AWS_REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME="autodecisionmaker-cluster"
SERVICE_NAME="autodecisionmaker-service"

# Check ECS Service
echo "?? ECS Service Status:"
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $AWS_REGION \
    --query 'services[0].[serviceName,status,runningCount,desiredCount]' \
    --output table

echo ""

# Check ALB
echo "?? Application Load Balancer:"
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names autodecisionmaker-alb \
    --region $AWS_REGION \
    --query 'LoadBalancers[0].DNSName' \
    --output text 2>/dev/null || echo "Not found")

if [ "$ALB_DNS" != "Not found" ] && [ -n "$ALB_DNS" ]; then
    echo "? Application URL: http://$ALB_DNS"
else
    echo "??  ALB not found or still creating..."
fi

echo ""

# Check ECR
echo "?? ECR Repository:"
aws ecr describe-repositories \
    --repository-names autodecisionmaker \
    --region $AWS_REGION \
    --query 'repositories[0].[repositoryName,repositoryUri]' \
    --output table 2>/dev/null || echo "??  ECR repository not found"

echo ""

# Check CloudWatch Logs
echo "?? Recent Logs:"
LOG_GROUP="/ecs/autodecisionmaker"
LATEST_STREAM=$(aws logs describe-log-streams \
    --log-group-name $LOG_GROUP \
    --region $AWS_REGION \
    --order-by LastEventTime \
    --descending \
    --query 'logStreams[0].logStreamName' \
    --output text 2>/dev/null)

if [ -n "$LATEST_STREAM" ] && [ "$LATEST_STREAM" != "None" ]; then
    echo "Latest log stream: $LATEST_STREAM"
    aws logs get-log-events \
        --log-group-name $LOG_GROUP \
        --log-stream-name $LATEST_STREAM \
        --region $AWS_REGION \
        --limit 10 \
        --query 'events[].message' \
        --output text
else
    echo "??  No logs found yet (service may still be starting)"
fi

echo ""
echo "? Status check complete"
