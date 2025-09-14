environment = "dev"
project_name = "bagisto"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# ECR Configuration - Update this with your actual ECR repository URL
ecr_repository_url = "ACCOUNT_ID.dkr.ecr.ap-southeast-2.amazonaws.com/bagisto-app"
image_tag = "latest"

# ECS Configuration
ecs_capacity_provider = "FARGATE_SPOT"
ecs_desired_count = 1

# RDS Configuration
db_instance_class = "db.r5.large"
