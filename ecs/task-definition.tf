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
        { name = "APP_URL", valueFrom = "/v2-dev/APP_URL" },
        { name = "AWS_REGION", valueFrom = "/v2-dev/AWS_REGION" },
        { name = "BCRYPT_ROUNDS", valueFrom = "/v2-dev/BCRYPT_ROUNDS" },
        { name = "COOKIE_SAME_SITE", valueFrom = "/v2-dev/COOKIE_SAME_SITE" },
        { name = "CORS_ORIGIN", valueFrom = "/v2-dev/CORS_ORIGIN" },
        { name = "DATABASE_URL", valueFrom = "/v2-dev/DATABASE_URL" },
        { name = "API_PREFIX", valueFrom = "/v2-dev/API_PREFIX" },
        { name = "S3_BUCKET_NAME", valueFrom = "/v2-dev/S3_BUCKET_NAME" },
        { name = "S3_SIGNED_URL_EXPIRY", valueFrom = "/v2-dev/S3_SIGNED_URL_EXPIRY" },
        { name = "DB_CONNECT_TIMEOUT", valueFrom = "/v2-dev/DB_CONNECT_TIMEOUT" },
        { name = "DB_IDLE_TIMEOUT", valueFrom = "/v2-dev/DB_IDLE_TIMEOUT" },
        { name = "DB_MAX_CONNECTIONS", valueFrom = "/v2-dev/DB_MAX_CONNECTIONS" },
        { name = "DEBUG_MODE", valueFrom = "/v2-dev/DEBUG_MODE" },
        { name = "ENCRYPTION_KEY", valueFrom = "/v2-dev/ENCRYPTION_KEY" },
        { name = "JWT_ACCESS_EXPIRES_IN", valueFrom = "/v2-dev/JWT_ACCESS_EXPIRES_IN" },
        { name = "JWT_REFRESH_EXPIRES_IN", valueFrom = "/v2-dev/JWT_REFRESH_EXPIRES_IN" },
        { name = "JWT_REFRESH_SECRET", valueFrom = "/v2-dev/JWT_REFRESH_SECRET" },
        { name = "JWT_SECRET", valueFrom = "/v2-dev/JWT_SECRET" },
        { name = "LOG_LEVEL", valueFrom = "/v2-dev/LOG_LEVEL" },
        { name = "LOG_FULL_CONTEXT", valueFrom = "/v2-dev/LOG_FULL_CONTEXT" },
        { name = "LOG_REQUEST_BODY", valueFrom = "/v2-dev/LOG_REQUEST_BODY" },
        { name = "LOG_RESPONSE_DATA", valueFrom = "/v2-dev/LOG_RESPONSE_DATA" },
        { name = "LOG_STACK_TRACES", valueFrom = "/v2-dev/LOG_STACK_TRACES" },
        { name = "LOG_SUCCESS_OPERATIONS", valueFrom = "/v2-dev/LOG_SUCCESS_OPERATIONS" },
        { name = "LOG_TO_DATABASE", valueFrom = "/v2-dev/LOG_TO_DATABASE" },
        { name = "MOCK_EMAILS", valueFrom = "/v2-dev/MOCK_EMAILS" },
        { name = "NODE_ENV", valueFrom = "/v2-dev/NODE_ENV" },
        { name = "PORT", valueFrom = "/v2-dev/PORT" },
        { name = "RATE_LIMIT_MAX_REQUESTS", valueFrom = "/v2-dev/RATE_LIMIT_MAX_REQUESTS" },
        { name = "RATE_LIMIT_WINDOW_MS", valueFrom = "/v2-dev/RATE_LIMIT_WINDOW_MS" },
        { name = "SQS_WORKER_ENABLED", valueFrom = "/v2-dev/SQS_WORKER_ENABLED" },
        { name = "SQS_WORKER_CONCURRENCY", valueFrom = "/v2-dev/SQS_WORKER_CONCURRENCY" },
        { name = "SQS_WORKER_POLL_INTERVAL_MS", valueFrom = "/v2-dev/SQS_WORKER_POLL_INTERVAL_MS" },
        { name = "SQS_WORKER_VISIBILITY_TIMEOUT", valueFrom = "/v2-dev/SQS_WORKER_VISIBILITY_TIMEOUT" },
        { name = "SQS_WORKER_MAX_RETRIES", valueFrom = "/v2-dev/SQS_WORKER_MAX_RETRIES" },
        { name = "QUEUE_WORKER_ENABLED", valueFrom = "/v2-dev/QUEUE_WORKER_ENABLED" },
        { name = "QUEUE_NUM_WORKERS", valueFrom = "/v2-dev/QUEUE_NUM_WORKERS" },
        { name = "QUEUE_CONCURRENCY", valueFrom = "/v2-dev/QUEUE_CONCURRENCY" },
        { name = "QUEUE_POLL_INTERVAL_MS", valueFrom = "/v2-dev/QUEUE_POLL_INTERVAL_MS" },
        { name = "QUEUE_MAX_RETRIES", valueFrom = "/v2-dev/QUEUE_MAX_RETRIES" },
        { name = "OUTBOX_BATCH_SIZE", valueFrom = "/v2-dev/OUTBOX_BATCH_SIZE" },
        { name = "OUTBOX_POLL_INTERVAL_MS", valueFrom = "/v2-dev/OUTBOX_POLL_INTERVAL_MS" },
        { name = "OUTBOX_RETENTION_DAYS", valueFrom = "/v2-dev/OUTBOX_RETENTION_DAYS" },
        { name = "QUEUE_CLEANUP_INTERVAL_MS", valueFrom = "/v2-dev/QUEUE_CLEANUP_INTERVAL_MS" },
        { name = "QUEUE_RETENTION_DAYS", valueFrom = "/v2-dev/QUEUE_RETENTION_DAYS" },
        { name = "QUEUE_RETRY_INTERVAL_MS", valueFrom = "/v2-dev/QUEUE_RETRY_INTERVAL_MS" },
        { name = "SES_RATE_LIMIT_PER_SECOND", valueFrom = "/v2-dev/SES_RATE_LIMIT_PER_SECOND" },
        { name = "SES_RATE_LIMIT_BURST", valueFrom = "/v2-dev/SES_RATE_LIMIT_BURST" },
        { name = "MAX_RECEIVE_COUNT", valueFrom = "/v2-dev/max_receive_count" },
        { name = "MESSAGE_RETENTION", valueFrom = "/v2-dev/message_retention" },
        { name = "VISIBILITY_TIMEOUT", valueFrom = "/v2-dev/visibility_timeout" }
      ]

      mountPoints = []
      volumesFrom = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/seaverse-backend-container-dev"
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