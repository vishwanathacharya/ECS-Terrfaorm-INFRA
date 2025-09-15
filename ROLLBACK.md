# 🔄 ECS Rollback Guide

## Quick Rollback to Previous Version

### Method 1: AWS Console (Fastest - 2 minutes)

#### Step 1: Find Previous Task Definition
1. Go to **ECS Console** → **Task Definitions**
2. Click on your task definition (e.g., `bagisto-staging-task`)
3. See all revisions (`:1`, `:2`, `:3`, etc.)
4. Note the **previous working revision number**

#### Step 2: Update Service
1. Go to **ECS Console** → **Clusters** → Your cluster
2. Click on **Services** tab
3. Select your service → **Update Service**
4. **Task Definition**: Select previous revision
5. **Force new deployment**: ✅ Check
6. Click **Update Service**

**Result: Rollback complete in 2-3 minutes!**

---

### Method 2: AWS CLI (Quick - 1 minute)

```bash
# List all task definition revisions
aws ecs list-task-definitions --family-prefix bagisto-staging-task --region ap-southeast-2

# Update service to previous revision
aws ecs update-service \
  --cluster bagisto-staging-cluster \
  --service bagisto-staging-service \
  --task-definition bagisto-staging-task:PREVIOUS_REVISION \
  --force-new-deployment \
  --region ap-southeast-2
```

---

### Method 3: Terraform (Infrastructure Level)

#### Option A: Change Image Tag
```bash
# Edit terraform.tfvars
vim environments/staging/terraform.tfvars

# Change image tag to previous commit
image_tag = "51b2a7a"  # Previous working commit SHA

# Apply changes
terraform apply -var-file="environments/staging/terraform.tfvars"
```

#### Option B: Use Specific ECR Image
```bash
# List available ECR images
aws ecr describe-images --repository-name bagisto-app --region ap-southeast-2

# Update terraform.tfvars with specific tag
image_tag = "67aec6e"  # Specific commit SHA

# Apply
terraform apply -var-file="environments/staging/terraform.tfvars"
```

---

### Method 4: Git Revert (Code Level)

```bash
# Revert to previous commit
git log --oneline  # Find commit to revert to
git revert HEAD    # Revert last commit
git push origin main

# This triggers new deployment with reverted code
```

---

## 🔍 How to Identify Issues

### Check Service Status
```bash
# Service health
aws ecs describe-services --cluster CLUSTER_NAME --services SERVICE_NAME --region ap-southeast-2

# Task status
aws ecs list-tasks --cluster CLUSTER_NAME --service-name SERVICE_NAME --region ap-southeast-2

# Task logs
aws logs get-log-events --log-group-name /ecs/bagisto-staging-task --log-stream-name STREAM_NAME --region ap-southeast-2
```

### Health Check Endpoints
- **Health Check**: `http://your-alb-url/health.php`
- **Database Test**: `http://your-alb-url/db-test.php`
- **PHP Info**: `http://your-alb-url/phpinfo.php`
- **Simple Test**: `http://your-alb-url/today.php`

---

## 📊 Available ECR Images

### Current Tags (Example)
```
latest          - Current deployment
ed730f4         - Health check fix
922afae         - Database test added
5282991         - PHP info test
67aec6e         - Laravel optimization
51b2a7a         - Working baseline
```

### Find Available Tags
```bash
# List all ECR images with tags
aws ecr describe-images \
  --repository-name bagisto-app \
  --region ap-southeast-2 \
  --query 'imageDetails[*].{Tags:imageTags,Pushed:imagePushedAt}' \
  --output table
```

---

## ⚡ Emergency Rollback (All Services)

```bash
# Rollback all services to previous revision
CLUSTER="bagisto-staging-cluster"
PREVIOUS_REVISION="bagisto-staging-task:2"  # Change this

# Web service
aws ecs update-service --cluster $CLUSTER --service bagisto-staging-service --task-definition $PREVIOUS_REVISION --force-new-deployment --region ap-southeast-2

# Queue workers
aws ecs update-service --cluster $CLUSTER --service bagisto-staging-queue-worker --task-definition $PREVIOUS_REVISION --force-new-deployment --region ap-southeast-2

# Scheduler
aws ecs update-service --cluster $CLUSTER --service bagisto-staging-scheduler --task-definition $PREVIOUS_REVISION --force-new-deployment --region ap-southeast-2
```

---

## 🎯 Best Practices

### Before Deployment
1. **Test in Dev** environment first
2. **Note current revision** number
3. **Check health endpoints** are working
4. **Backup database** if needed

### After Deployment
1. **Monitor health checks** for 5 minutes
2. **Test critical functionality**
3. **Check application logs**
4. **Verify database connectivity**

### Rollback Decision
- **Health checks failing** → Immediate rollback
- **500 errors** → Check logs, consider rollback
- **Database issues** → Rollback and investigate
- **Performance degradation** → Monitor, rollback if severe

---

## 📞 Troubleshooting

### Common Issues & Solutions

| Issue | Quick Fix |
|-------|-----------|
| Health checks failing | Rollback to previous revision |
| 500 Internal Server Error | Check `/db-test.php`, rollback if DB issue |
| Tasks not starting | Check task definition, resource limits |
| Load balancer 503 | No healthy targets, rollback immediately |
| Database connection failed | Check RDS status, security groups |

### Emergency Contacts
- **AWS Console**: Direct service updates
- **GitHub Actions**: Check pipeline status
- **CloudWatch**: Monitor logs and metrics

---

**Remember: AWS Console method is fastest for emergency rollbacks!** 🚀
