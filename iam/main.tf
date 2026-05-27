resource "aws_iam_role" "ecs_full_access_role" {
  name = "${var.project}-${var.environment}-ecs-full-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
    tags = local.common_tags   
}

resource "aws_iam_role_policy" "ecs_full_policy" {
  name = "ecs-full-access-policy"
  role = aws_iam_role.ecs_full_access_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ✅ ECR (pull images)
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },

      # ✅ CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      # ✅ RDS (Aurora access)
      {
        Effect = "Allow"
        Action = [
          "rds:*"
        ]
        Resource = "*"
      },

      # ✅ ECS (optional internal calls)
      {
        Effect = "Allow"
        Action = [
          "ecs:*"
        ]
        Resource = "*"
      },

      # ✅ EC2 (network interfaces for Fargate)
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },

      # ✅ SSM access (ADDED)
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }

    ]
  })
}