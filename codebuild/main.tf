provider "aws" {
  region = var.region
}
# CodeBuild IAM Role

resource "aws_iam_role" "codebuild" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Administrator Access Policy
resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
# Frontend

resource "aws_codebuild_project" "frontend" {
  name         = "Seaverse-frontend"
  description  = "Frontend Build"
  service_role = aws_iam_role.codebuild.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/swatigadagi/DevOps_Project_2.git"
    git_clone_depth = 1
    buildspec       = "Frontend_buildspec.yaml"
  }

  # Artifacts stored Frontend
  artifacts {
    type      = "S3"
    location  = var.bucket_name
    path      = "Frontend"
    name      = "frontend-build"
    packaging = "NONE"
  }

  environment {
    compute_type    = var.compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }
}

# Backend

resource "aws_codebuild_project" "backend" {
  name         = "Backend"
  description  = "Backend Build"
  service_role = aws_iam_role.codebuild.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/swatigadagi/DevOps_Project_2.git"
    git_clone_depth = 1
    buildspec       = "Backend_buildspec.yaml"
  }

  # Artifacts stored Backend
  artifacts {
    type      = "S3"
    location  = var.bucket_name
    path      = "Backend"
    name      = "backend-build"
    packaging = "ZIP"
  }
  environment {
    compute_type    = var.compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
}
