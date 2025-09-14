environment = "staging"
project_name = "bagisto"

# VPC Configuration
vpc_cidr = "10.1.0.0/16"

# ECR Configuration
ecr_repository_url = "YOUR_ACCOUNT.dkr.ecr.ap-southeast-2.amazonaws.com/bagisto-app"
image_tag = "latest"

# ECS Configuration
ecs_capacity_provider = "FARGATE_SPOT"
ecs_desired_count = 2

# RDS Configuration
db_instance_class = "db.r6g.large"
