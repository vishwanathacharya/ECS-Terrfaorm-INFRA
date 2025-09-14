# Bagisto ECS Infrastructure - Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20RDS%20%7C%20S3-orange)](https://aws.amazon.com)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-as%20Code-blue)](https://www.terraform.io/use-cases/infrastructure-as-code)

Production-ready Terraform infrastructure for deploying Bagisto e-commerce platform on AWS ECS with microservices architecture, auto-scaling, and multi-environment support.

## 🏗️ Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS Cloud                              │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    VPC (10.x.0.0/16)                       ││
│  │                                                             ││
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     ││
│  │  │Public Subnet │  │Public Subnet │  │Public Subnet │     ││
│  │  │    AZ-1a     │  │    AZ-1b     │  │    AZ-1c     │     ││
│  │  │     ALB      │  │     NAT      │  │   Reserved   │     ││
│  │  └──────────────┘  └──────────────┘  └──────────────┘     ││
│  │                                                             ││
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     ││
│  │  │Private Subnet│  │Private Subnet│  │Private Subnet│     ││
│  │  │    AZ-1a     │  │    AZ-1b     │  │    AZ-1c     │     ││
│  │  │ ECS Services │  │ ECS Services │  │ RDS Cluster  │     ││
│  │  └──────────────┘  └──────────────┘  └──────────────┘     ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
ECS-Terrfaorm-INFRA/
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars    # Development configuration
│   │   └── backend.tf          # Dev state backend
│   ├── staging/
│   │   ├── terraform.tfvars    # Staging configuration
│   │   └── backend.tf          # Staging state backend
│   └── production/
│       ├── terraform.tfvars    # Production configuration
│       └── backend.tf          # Production state backend
├── .github/workflows/
│   ├── deploy-dev.yml          # Dev deployment pipeline
│   ├── deploy-staging.yml      # Staging deployment pipeline
│   ├── deploy-production.yml   # Production deployment pipeline
│   └── destroy-environment.yml # Environment cleanup
├── main.tf                     # Provider configuration
├── vpc.tf                      # VPC, subnets, gateways
├── security-groups.tf          # Security group rules
├── alb.tf                      # Application Load Balancer
├── ecs.tf                      # Web server ECS service
├── queue-worker.tf             # Queue worker ECS service
├── scheduler.tf                # Scheduler ECS service
├── rds.tf                      # MySQL database cluster
├── s3.tf                       # Media files storage
├── cloudfront.tf               # CDN distribution
├── iam.tf                      # IAM roles and policies
├── outputs.tf                  # Infrastructure outputs
├── variables.tf                # Input variables
└── README.md                   # This documentation
```

## 🚀 Quick Start

### **Prerequisites**
- AWS CLI configured with appropriate permissions
- Terraform 1.5+ installed
- GitHub repository access for CI/CD

### **Manual Deployment**

1. **Clone Repository**
   ```bash
   git clone https://github.com/vishwanathacharya/ECS-Terrfaorm-INFRA.git
   cd ECS-Terrfaorm-INFRA
   ```

2. **Initialize Terraform**
   ```bash
   # Copy environment-specific backend configuration
   cp environments/staging/backend.tf .
   
   # Initialize Terraform
   terraform init
   ```

3. **Plan Deployment**
   ```bash
   # Review infrastructure changes
   terraform plan -var-file="environments/staging/terraform.tfvars"
   ```

4. **Deploy Infrastructure**
   ```bash
   # Apply infrastructure changes
   terraform apply -var-file="environments/staging/terraform.tfvars"
   ```

### **Automated Deployment (Recommended)**

Push to respective branches to trigger automated deployment:

```bash
# Deploy to development
git push origin dev

# Deploy to staging  
git push origin staging

# Deploy to production
git push origin production
```

## 🌍 Environment Configurations

### **Development Environment**
```hcl
environment = "dev"
vpc_cidr = "10.0.0.0/16"
ecs_capacity_provider = "FARGATE_SPOT"  # 70% cost savings
ecs_desired_count = 1
db_instance_class = "db.r5.large"
```

### **Staging Environment**
```hcl
environment = "staging"
vpc_cidr = "10.1.0.0/16"
ecs_capacity_provider = "FARGATE_SPOT"
ecs_desired_count = 1
db_instance_class = "db.r5.large"
```

### **Production Environment**
```hcl
environment = "production"
vpc_cidr = "10.2.0.0/16"
ecs_capacity_provider = "FARGATE"        # High availability
ecs_desired_count = 2
db_instance_class = "db.r5.xlarge"
```

## 🏗️ Infrastructure Components

### **Networking (vpc.tf)**
- **VPC:** Isolated network environment
- **Subnets:** Public (ALB, NAT) + Private (ECS, RDS)
- **Gateways:** Internet Gateway + NAT Gateway
- **Route Tables:** Public and private routing

### **Security (security-groups.tf)**
- **ALB Security Group:** HTTP/HTTPS from internet
- **ECS Security Group:** Traffic from ALB only
- **RDS Security Group:** MySQL from ECS only

### **Load Balancing (alb.tf)**
- **Application Load Balancer:** Layer 7 load balancing
- **Target Groups:** Health check configuration
- **Listeners:** HTTP to HTTPS redirect

### **Compute Services**

#### **Web Server (ecs.tf)**
- **Service Type:** ECS Fargate
- **Container:** nginx + php-fpm
- **Scaling:** 1-5 containers based on CPU
- **Health Check:** HTTP endpoint monitoring

#### **Queue Workers (queue-worker.tf)**
- **Service Type:** ECS Fargate
- **Container:** Laravel queue worker
- **Scaling:** 1-10 containers based on queue depth
- **Command:** `php artisan queue:work`

#### **Scheduler (scheduler.tf)**
- **Service Type:** ECS Fargate
- **Container:** Laravel task scheduler
- **Scaling:** Fixed 1 container
- **Command:** `php artisan schedule:run`

### **Database (rds.tf)**
- **Engine:** MySQL 8.0
- **Configuration:** Aurora Serverless v2 cluster
- **Availability:** Multi-AZ with automatic failover
- **Backup:** Automated daily backups (7-30 days retention)
- **Security:** Encrypted at rest and in transit

### **Storage & CDN**

#### **S3 Storage (s3.tf)**
- **Bucket:** Media files storage
- **Versioning:** Enabled for production
- **Lifecycle:** Standard → IA (30d) → Glacier (90d)
- **CORS:** Cross-origin resource sharing enabled

#### **CloudFront CDN (cloudfront.tf)**
- **Distribution:** Global content delivery
- **Caching:** Optimized for images (1 day TTL)
- **Compression:** Automatic gzip compression
- **Security:** HTTPS enforcement

### **Security & Access (iam.tf)**
- **ECS Execution Role:** Container startup permissions
- **ECS Task Role:** Application runtime permissions
- **S3 Access Policy:** Media files read/write
- **Secrets Manager:** Database credentials access

## 📊 Monitoring & Outputs

### **Infrastructure Outputs**
```hcl
# Network Information
vpc_id                    # VPC identifier
alb_dns_name             # Load balancer endpoint

# ECS Information  
ecs_cluster_name         # ECS cluster name
ecs_service_name         # Web service name

# Database Information
rds_cluster_endpoint     # Database writer endpoint
rds_cluster_reader_endpoint  # Database reader endpoint

# Storage Information
s3_bucket_name           # Media files bucket
cloudfront_domain_name   # CDN distribution domain
```

### **CloudWatch Monitoring**
- **ECS Services:** CPU, memory, task count metrics
- **ALB:** Request count, latency, error rates
- **RDS:** Database connections, CPU, storage
- **S3:** Request metrics, storage utilization

## 🔒 Security Best Practices

### **Network Security**
- **Private Subnets:** Application containers isolated from internet
- **Security Groups:** Restrictive ingress/egress rules
- **NACLs:** Additional network-level protection

### **Data Security**
- **Encryption at Rest:** RDS, S3, EBS volumes
- **Encryption in Transit:** HTTPS, SSL/TLS
- **Secrets Management:** AWS Secrets Manager integration

### **Access Control**
- **IAM Roles:** Least privilege principle
- **Resource Policies:** Fine-grained access control
- **VPC Endpoints:** Private AWS service access

## 💰 Cost Optimization

### **Compute Optimization**
- **Fargate Spot:** 70% savings for non-production
- **Right-sizing:** Optimized CPU/memory allocation
- **Auto-scaling:** Scale down during low usage

### **Storage Optimization**
- **S3 Lifecycle:** Automatic tier transitions
- **CloudFront:** Reduced origin requests
- **RDS:** Aurora Serverless v2 scaling

### **Monitoring Costs**
- **AWS Cost Explorer:** Track spending by service
- **Budgets:** Set spending alerts
- **Resource Tagging:** Cost allocation tracking

## 🔄 CI/CD Pipeline

### **GitHub Actions Workflows**

#### **Development Pipeline**
```yaml
# Triggered on: push to dev branch
# Target: Development environment
# Compute: Fargate Spot
# Database: Single instance
```

#### **Staging Pipeline**
```yaml
# Triggered on: push to staging branch  
# Target: Staging environment
# Compute: Fargate Spot
# Database: Cluster with reader
```

#### **Production Pipeline**
```yaml
# Triggered on: push to production branch
# Target: Production environment
# Compute: Fargate (high availability)
# Database: Multi-AZ cluster
```

### **Deployment Process**
1. **Terraform Plan:** Review infrastructure changes
2. **Terraform Apply:** Deploy infrastructure updates
3. **ECS Service Update:** Force new deployment
4. **Health Check:** Verify service availability

## 🛠️ Maintenance & Operations

### **Regular Maintenance**
- **Terraform State:** Backed up to S3 with versioning
- **Infrastructure Updates:** Monthly Terraform version updates
- **Security Patches:** Automated OS updates via ECS
- **Cost Review:** Monthly cost optimization analysis

### **Disaster Recovery**
- **Multi-AZ:** Automatic failover capability
- **Backups:** Daily automated database backups
- **Infrastructure:** Reproducible via Terraform
- **Recovery Time:** < 15 minutes for most scenarios

### **Scaling Operations**
```bash
# Scale ECS services
aws ecs update-service --cluster bagisto-prod-cluster \
  --service bagisto-prod-service --desired-count 5

# Scale database
aws rds modify-db-cluster --db-cluster-identifier bagisto-prod \
  --scaling-configuration MinCapacity=2,MaxCapacity=16
```

## 🔧 Troubleshooting

### **Common Issues**

#### **ECS Service Won't Start**
```bash
# Check service events
aws ecs describe-services --cluster CLUSTER_NAME --services SERVICE_NAME

# Check task definition
aws ecs describe-task-definition --task-definition TASK_DEFINITION_ARN
```

#### **Database Connection Issues**
```bash
# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Test connectivity from ECS
aws ecs execute-command --cluster CLUSTER --task TASK_ID --command "nc -zv DB_HOST 3306"
```

#### **S3 Access Issues**
```bash
# Check IAM permissions
aws iam simulate-principal-policy --policy-source-arn ROLE_ARN \
  --action-names s3:GetObject --resource-arns BUCKET_ARN/*
```

## 📞 Support & Documentation

### **AWS Documentation**
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [RDS Aurora Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)

### **Terraform Resources**
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

### **Application Repository**
[Bagisto ECS Application](https://github.com/vishwanathacharya/ECS-BagistoV2.2.2)

---

**Infrastructure as Code with ❤️ using Terraform and AWS**

*Last Updated: September 2025*
