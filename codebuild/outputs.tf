
output "frontend_project_name" {
  value = aws_codebuild_project.frontend.name
}

output "backend_project_name" {
  value = aws_codebuild_project.backend.name
}

output "worker_project_name" {
  value = aws_codebuild_project.worker.name
}