provider "aws" {
  region = var.region
}

# CodeBuild IAM Role

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
    type            = "BITBUCKET"
    location        = "https://sumati1@bitbucket.org/lms-seaverse/seaverse-frontend-v2-demo.git"
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

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "DEPLOY_TYPE"
      value = var.deploy_type
    }

    environment_variable {
      name  = "SSM_PATH"
      value = var.ssm_path
    }

    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = var.artifact_bucket
    }
  }
}

# Backend

resource "aws_codebuild_project" "backend" {
  name         = "Seaverse-backend"
  description  = "Backend Build"
  service_role = aws_iam_role.codebuild.arn

  source {
    type            = "BITBUCKET"
    location        = "https://sumati1@bitbucket.org/lms-seaverse/seaverse-backend-v2-demo.git"
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

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "DEPLOY_TYPE"
      value = var.deploy_type
    }

    environment_variable {
      name  = "SSM_PATH"
      value = var.ssm_path
    }

    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = var.artifact_bucket
    }
  }
}
