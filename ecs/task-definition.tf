resource "aws_ecs_task_definition" "this" {
  family                   = "backend-container-dev"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "8192"
  memory                   = "16384"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "${var.project}-container"
      image     = "${var.container_image}"
      cpu       = 0
      essential = true
      portMappings = [{
        name          = "${lower(var.project)}-container-${var.container_port}-tcp"
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
        appProtocol   = "http"
      }]
      environment = []
        secrets = [
           { name = "ALLOWED_SSH_CIDR", valueFrom = "/terraform/allowed_ssh_cidr" },
           { name = "BACKEND_PORT",     valueFrom = "/terraform/backend_port" },
           { name = "CERTIFICATE_ARN",  valueFrom = "/terraform/certificate_arn" },
           { name = "CONTAINER_PORT",   valueFrom = "/terraform/container_port" },
           { name = "ENVIRONMENT",      valueFrom = "/terraform/environment" },
           { name = "MASTER_PASSWORD",  valueFrom = "/terraform/master_password" },
           { name = "MASTER_USERNAME",  valueFrom = "/terraform/master_username" },
           { name = "MAX_CAPACITY",     valueFrom = "/terraform/max_capacity" },
           { name = "MIN_CAPACITY",     valueFrom = "/terraform/min_capacity" },
           { name = "NAME",             valueFrom = "/terraform/name" },
           { name = "PROJECT",          valueFrom = "/terraform/project" },
           { name = "REGION",           valueFrom = "/terraform/region" },
           { name = "PORT",             valueFrom = "/terraform/PORT" },
           { name = "DB_HOST",          valueFrom = "/terraform/DB_HOST" },
           { name = "DB_PORT",          valueFrom = "/terraform/DB_PORT" },
           { name = "DB_USER",          valueFrom = "/terraform/DB_USER" },
           { name = "DB_PASSWORD",      valueFrom = "/terraform/DB_PASSWORD" },
           { name = "DB_NAME",          valueFrom = "/terraform/DB_NAME" }
         ]
      mountPoints = []
      volumesFrom = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/backend-container-prod"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
        secretOptions = []
      }

      systemControls = []
    }
  ])

  tags = {
    Environment = var.environment
  }
}
