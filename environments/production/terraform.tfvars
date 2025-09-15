environment = "production"
project_name = "bagisto"

# VPC Configuration
vpc_cidr = "10.2.0.0/16"

# ECR Configuration
ecr_repository_url = "556612399991.dkr.ecr.ap-southeast-2.amazonaws.com/bagisto-app"
image_tag = "latest"

# ECS Configuration
ecs_capacity_provider = "FARGATE"
ecs_desired_count = 2  # 2 web servers for production

# RDS Configuration
db_instance_class = "db.r5.large"
