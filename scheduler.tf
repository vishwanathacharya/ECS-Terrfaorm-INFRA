# Scheduler Task Definition
resource "aws_ecs_task_definition" "scheduler" {
  family                   = "${local.name_prefix}-scheduler"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "scheduler"
      image = "${var.ecr_repository_url}:${var.image_tag}"
      
      # Override command to run scheduler
      command = ["sh", "-c", "while true; do php /var/www/html/artisan schedule:run --verbose --no-interaction; sleep 60; done"]

      environment = [
        {
          name  = "APP_ENV"
          value = var.environment
        },
        {
          name  = "APP_KEY"
          value = "base64:YourBase64EncodedKeyHere1234567890ABCDEF="
        },
        {
          name  = "APP_DEBUG"
          value = var.environment == "production" ? "false" : "true"
        },
        {
          name  = "QUEUE_CONNECTION"
          value = "database"
        }
      ]

      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "DB_DATABASE"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:dbname::"
        },
        {
          name      = "DB_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.scheduler.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "scheduler"
        }
      }

      essential = true
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-scheduler"
  })
}

# Scheduler Service
resource "aws_ecs_service" "scheduler" {
  name            = "${local.name_prefix}-scheduler"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count   = 1  # Only 1 scheduler needed
  
  # Use capacity provider strategy instead of launch_type
  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider
    weight           = 100
    base             = 1
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = aws_subnet.private[*].id
    assign_public_ip = false
  }

  # No load balancer needed for scheduler

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-scheduler"
  })
}

# CloudWatch Log Group for Scheduler
resource "aws_cloudwatch_log_group" "scheduler" {
  name              = "/ecs/${local.name_prefix}-scheduler"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-scheduler-logs"
  })
}
