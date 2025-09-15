# Queue Worker Task Definition
resource "aws_ecs_task_definition" "queue_worker" {
  family                   = "${local.name_prefix}-queue-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "queue-worker"
      image = "${var.ecr_repository_url}:${var.image_tag}"
      
      # Override command to run only queue worker
      command = ["php", "/var/www/html/artisan", "queue:work", "--sleep=3", "--tries=3", "--max-time=3600"]

      environment = [
        {
          name  = "APP_ENV"
          value = var.environment
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
          "awslogs-group"         = aws_cloudwatch_log_group.queue_worker.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "queue"
        }
      }

      essential = true
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-queue-worker"
  })
}

# Queue Worker Service
resource "aws_ecs_service" "queue_worker" {
  name            = "${local.name_prefix}-queue-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.queue_worker.arn
  desired_count   = var.environment == "production" ? 2 : 1  # 2 for prod, 1 for dev/staging
  
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

  # No load balancer needed for queue workers

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-queue-worker"
  })
}

# CloudWatch Log Group for Queue Workers
resource "aws_cloudwatch_log_group" "queue_worker" {
  name              = "/ecs/${local.name_prefix}-queue"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-queue-logs"
  })
}
