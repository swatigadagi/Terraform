resource "aws_ecs_task_definition" "this" {
  family                   = "seaverse-backend-container-dev"
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
        { name = "PORT", valueFrom = "/v2-dev/PORT" },
        { name = "NODE_ENV", valueFrom = "/v2-dev/NODE_ENV" },
        { name = "CORS_ORIGIN", valueFrom = "/v2-dev/CORS_ORIGIN" }
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
