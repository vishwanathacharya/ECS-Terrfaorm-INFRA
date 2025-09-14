# AWS ECS Infrastructure for Bagisto E-commerce

## 🚀 Overview
Complete AWS infrastructure for deploying Bagisto e-commerce application using ECS Fargate, Aurora MySQL, and optional S3/CloudFront for media storage.

**📅 Last Updated:** 2025-01-14 07:59 UTC  
**🔄 Status:** Active Development  
**✅ Pipeline:** Automated Deployment Ready

## 🏗️ Architecture
```
Internet → ALB → ECS Fargate → Aurora MySQL
                    ↓
              S3 + CloudFront (Optional)
```

## 📊 Current Deployment Status

### **Active Environments:**
- ✅ **Development**: `bagisto-dev-alb-*.ap-southeast-2.elb.amazonaws.com`
- 🔄 **Staging**: Ready for deployment
- 🚀 **Production**: Ready for deployment

### **Infrastructure Health:**
- ✅ **ECS Fargate**: Running and healthy
- ✅ **Aurora MySQL**: Database operational
- ✅ **Application Load Balancer**: Traffic routing active
- ✅ **VPC & Security Groups**: Network secured
- ✅ **Secrets Manager**: Credentials managed

### **Recent Updates:**
- 🔧 Fixed ECS capacity provider destruction issues
- 🗑️ Added comprehensive destroy workflows
- 📚 Enhanced documentation and troubleshooting guides
- ⚡ Optimized deployment pipelines

## 📁 Project Structure
```
ECS-Terraform-INFRA/
├── .github/workflows/           # GitHub Actions workflows
│   ├── deploy-dev.yml          # Deploy dev environment
│   ├── deploy-staging.yml      # Deploy staging environment  
│   ├── deploy-production.yml   # Deploy production environment
│   ├── destroy-environment.yml # Destroy specific environment
│   └── emergency-destroy.yml   # Destroy all environments
├── environments/               # Environment-specific configurations
│   ├── dev/
│   │   ├── backend.tf         # Terraform backend for dev
│   │   └── terraform.tfvars   # Dev environment variables
│   ├── staging/
│   │   ├── backend.tf         # Terraform backend for staging
│   │   └── terraform.tfvars   # Staging environment variables
│   └── production/
│       ├── backend.tf         # Terraform backend for production
│       └── terraform.tfvars   # Production environment variables
├── alb.tf                     # Application Load Balancer
├── cloudfront.tf              # CloudFront distribution (optional)
├── ecs.tf                     # ECS cluster, service, and tasks
├── iam.tf                     # IAM roles and policies
├── locals.tf                  # Local values and tags
├── outputs.tf                 # Terraform outputs
├── provider.tf                # AWS provider configuration
├── rds.tf                     # Aurora MySQL cluster
├── s3.tf                      # S3 bucket for media (optional)
├── security_groups.tf         # Security group rules
├── variables.tf               # Input variables
├── vpc.tf                     # VPC and networking
└── README.md                  # This file
```

## 🛠️ Infrastructure Components

### Core Services
- **VPC**: Custom VPC with public/private subnets
- **ECS Fargate**: Serverless container platform
- **Aurora MySQL**: Managed database cluster
- **Application Load Balancer**: Traffic distribution
- **Secrets Manager**: Secure credential storage

### Optional Services (Currently Disabled)
- **S3 Bucket**: Media file storage
- **CloudFront**: Global CDN for media delivery

### Security
- **Security Groups**: Network access control
- **IAM Roles**: Least privilege access
- **Private Subnets**: Database isolation
- **Secrets Management**: Encrypted credential storage

## 🌍 Environments

### Development
- **VPC CIDR**: `10.0.0.0/16`
- **Instance Class**: `db.r5.large`
- **ECS Capacity**: Fargate Spot
- **Desired Count**: 1 task

### Staging  
- **VPC CIDR**: `10.1.0.0/16`
- **Instance Class**: `db.r5.large`
- **ECS Capacity**: Fargate Spot
- **Desired Count**: 1 task

### Production
- **VPC CIDR**: `10.2.0.0/16`
- **Instance Class**: `db.r5.large`
- **ECS Capacity**: Fargate On-Demand
- **Desired Count**: 1 task

## 🚀 Deployment Workflows

### 1. Environment-Specific Deployment
**Triggers**: 
- Push to `main` branch (dev environment)
- Push to `staging` branch (staging environment)
- Push to `production` branch (production environment)
- Manual dispatch

**Steps**:
1. Terraform initialization
2. Infrastructure planning
3. Resource deployment
4. Output generation

### 2. Selective Environment Destruction
**Trigger**: Manual dispatch only
**Safety**: Requires typing "DESTROY"
**Options**: Choose dev, staging, or production
**Action**: Destroys selected environment only

### 3. Emergency Destroy All
**Trigger**: Manual dispatch only
**Safety**: Requires typing "EMERGENCY-DESTROY-ALL"
**Action**: Destroys ALL environments simultaneously

## 📋 Prerequisites
- AWS Account with appropriate permissions
- GitHub repository secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- S3 buckets for Terraform state (per environment)
- ECR repository with Bagisto application image

## 🔧 Local Development

### Initialize Terraform
```bash
# Copy environment backend
cp environments/dev/backend.tf .

# Initialize
terraform init

# Plan deployment
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Environment Variables
Each environment requires:
```hcl
environment = "dev"
project_name = "bagisto"
vpc_cidr = "10.0.0.0/16"
ecr_repository_url = "556612399991.dkr.ecr.ap-southeast-2.amazonaws.com/bagisto-app"
image_tag = "latest"
ecs_capacity_provider = "FARGATE_SPOT"
ecs_desired_count = 1
db_instance_class = "db.r5.large"
```

## 🌐 Access URLs
After deployment:
- **Dev**: `http://bagisto-dev-alb-*.ap-southeast-2.elb.amazonaws.com/`
- **Staging**: `http://bagisto-staging-alb-*.ap-southeast-2.elb.amazonaws.com/`
- **Production**: `http://bagisto-production-alb-*.ap-southeast-2.elb.amazonaws.com/`

## 📊 Resource Outputs
```bash
# Get ALB endpoint
terraform output alb_dns_name

# Get database endpoint
terraform output rds_cluster_endpoint

# Get ECS cluster name
terraform output ecs_cluster_name
```

## 🗑️ Cleanup Options

### Destroy Specific Environment
1. Go to GitHub Actions
2. Run "Destroy Environment" workflow
3. Select environment (dev/staging/production)
4. Type "DESTROY" when prompted

### Emergency Destroy All
1. Go to GitHub Actions
2. Run "Emergency Destroy All" workflow
3. Type "EMERGENCY-DESTROY-ALL" when prompted
4. All environments will be destroyed

## 💰 Cost Optimization
- **Fargate Spot**: 70% cost savings for dev/staging
- **Aurora Serverless**: Pay-per-use database scaling
- **Lifecycle Policies**: Automatic resource cleanup
- **Environment Isolation**: Deploy only needed environments

## 🔒 Security Best Practices
- Private subnets for database
- Security groups with minimal access
- IAM roles with least privilege
- Secrets Manager for credentials
- VPC isolation between environments

## 🆘 Troubleshooting

### Common Issues
1. **ECR Image Not Found**: Deploy ECR repository first
2. **Database Connection**: Check security groups
3. **Task Failures**: Verify environment variables
4. **Permission Denied**: Check IAM roles

### Debug Commands
```bash
# Check ECS service status
aws ecs describe-services --cluster bagisto-dev-cluster --services bagisto-dev-service

# Check task logs
aws logs get-log-events --log-group-name /ecs/bagisto-dev-task

# Check database connectivity
aws rds describe-db-clusters --db-cluster-identifier bagisto-dev-aurora-cluster
```

## 📚 Related Repositories
- **Application Code**: [Bagisto Repository](../bagisto) - Application source code and ECR deployment
- **Infrastructure**: This repository - Complete AWS infrastructure

## 🔄 CI/CD Pipeline
1. **Code Push** → Bagisto repository
2. **Image Build** → ECR repository update
3. **ECS Update** → Automatic service deployment
4. **Health Check** → ALB health verification
5. **Traffic Switch** → Zero-downtime deployment

## 📈 Monitoring & Logging
- **CloudWatch Logs**: ECS task logs
- **ALB Access Logs**: Request tracking
- **CloudWatch Metrics**: Performance monitoring
- **Health Checks**: Application availability

## 🎯 Future Enhancements
- [ ] Auto Scaling based on CPU/Memory
- [ ] Custom domain with Route 53
- [ ] SSL/TLS certificates with ACM
- [ ] WAF for security protection
- [ ] ElastiCache for session storage
- [ ] RDS Read Replicas for scaling
