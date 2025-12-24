# AWS ECS Infrastructure as Code

This directory contains Terraform configuration for deploying the AutoDecisionMaker application to AWS ECS Fargate.

## File Structure

```
terraform/
??? provider.tf          # AWS provider configuration
??? variables.tf         # Input variables
??? vpc.tf              # VPC, subnets, NAT, routing
??? alb.tf              # Application Load Balancer
??? ecs.tf              # ECS cluster, task definition, service
??? ecr.tf              # ECR repository
??? outputs.tf          # Output values
??? terraform.tfvars.example  # Example variables
```

## Quick Start

1. **Copy variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit variables**
   ```bash
   vim terraform.tfvars
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan changes**
   ```bash
   terraform plan
   ```

5. **Apply changes**
   ```bash
   terraform apply
   ```

## Infrastructure Components

### VPC & Networking
- VPC with 10.0.0.0/16 CIDR
- 2 Public subnets (for ALB)
- 2 Private subnets (for ECS tasks)
- NAT Gateway for outbound traffic
- Internet Gateway for inbound traffic

### Load Balancing
- Application Load Balancer (ALB)
- Target group for ECS tasks
- Health checks configured

### ECS Fargate
- ECS Cluster with Container Insights
- Task Definition (256 CPU, 512 MB RAM)
- ECS Service with ALB integration
- Auto Scaling (1-3 tasks)

### ECR
- Private ECR repository
- Image scanning on push
- Lifecycle policy (keep last 5 images)

### Security
- Security groups for ALB and ECS tasks
- IAM roles for task execution
- IAM roles for task permissions

### Monitoring
- CloudWatch Log Group
- ECS Container Insights
- Auto Scaling metrics

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | us-east-1 | AWS region |
| `app_name` | autodecisionmaker | Application name |
| `environment` | dev | Environment (dev/staging/prod) |
| `container_port` | 8080 | Container port |
| `container_cpu` | 256 | CPU units |
| `container_memory` | 512 | Memory in MB |
| `desired_count` | 1 | Initial number of tasks |
| `container_image` | - | Docker image URI (required) |
| `enable_autoscaling` | true | Enable auto scaling |
| `min_capacity` | 1 | Minimum tasks |
| `max_capacity` | 3 | Maximum tasks |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | DNS name of the ALB |
| `ecr_repository_url` | ECR repository URL |
| `ecs_cluster_name` | ECS cluster name |
| `ecs_service_name` | ECS service name |
| `cloudwatch_log_group` | CloudWatch log group |

## Cost Optimization

- Uses **Fargate Spot** (70% cheaper)
- Minimal resource allocation
- Auto-scaling (scales down when idle)
- Can be destroyed when not in use

## Common Commands

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply plan
terraform apply tfplan

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Refresh state
terraform refresh
```

## Environment-Specific Setup

### Development
```hcl
environment    = "dev"
container_cpu  = "256"
container_memory = "512"
min_capacity   = 1
max_capacity   = 2
```

### Production
```hcl
environment    = "prod"
container_cpu  = "512"
container_memory = "1024"
min_capacity   = 2
max_capacity   = 10
```

## Troubleshooting

### Error: "Error: error reading S3 Bucket Versioning"

**Solution**: Ensure AWS credentials are correctly configured.

### Error: "InvalidParameterException: Invalid cpu/memory combination"

**Solution**: Use valid ECS Fargate CPU/memory combinations:
- 256: 512, 1024, 2048
- 512: 1024-4096
- 1024: 2048-8192
- 2048: 4096-16384
- 4096: 8192-30720

### Application not accessible

1. Check ECS service task status
2. Verify ALB target group health
3. Check security group rules
4. Review CloudWatch logs

## Security Considerations

- ECS tasks run in private subnets
- Only ALB is publicly accessible
- ECR is private with image scanning
- IAM roles follow least privilege
- No hardcoded credentials

## See Also

- [IaC-GUIDE.md](../IaC-GUIDE.md) - Comprehensive guide
- [GitHub Actions Workflow](.github/workflows/deploy.yml) - CI/CD pipeline
