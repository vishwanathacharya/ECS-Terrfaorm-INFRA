# Bagisto ECS Infrastructure

Complete Terraform infrastructure for deploying Bagisto application across multiple environments.

## Architecture

- **VPC**: Isolated network with public/private subnets
- **ALB**: Application Load Balancer for traffic distribution
- **ECS Fargate**: Container orchestration (Spot instances for dev/staging, On-demand for production)
- **RDS Aurora**: MySQL database cluster
- **Secrets Manager**: Secure database credentials storage

## Environments

### Dev Environment
- **Branch**: `dev`
- **Capacity**: Fargate Spot instances
- **Database**: Single Aurora instance
- **Resources**: Minimal for cost optimization

### Staging Environment  
- **Branch**: `staging`
- **Capacity**: Fargate Spot instances
- **Database**: Single Aurora instance
- **Resources**: Testing optimized

### Production Environment
- **Branch**: `production` 
- **Capacity**: Fargate On-demand instances
- **Database**: Multi-AZ Aurora cluster
- **Resources**: High availability and performance

## Deployment

### Prerequisites
1. Update ECR repository URL in `environments/*/terraform.tfvars`
2. Configure GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Branch-based Deployment
- Push to `dev` branch → Deploys dev environment
- Push to `staging` branch → Deploys staging environment  
- Push to `production` branch → Deploys production environment
- Push to `terraform` branch → No deployment (development only)

### Manual Deployment
```bash
# Initialize environment
cp environments/dev/backend.tf .
terraform init

# Plan deployment
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"
```

## Outputs

Each environment provides:
- ALB DNS name for application access
- ECS cluster and service names
- RDS endpoints
- Secrets Manager ARN for database credentials

## Security

- Database credentials stored in AWS Secrets Manager
- ECS tasks retrieve secrets at runtime
- Security groups restrict network access
- Private subnets for application and database tiers
