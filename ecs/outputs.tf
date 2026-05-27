output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.this.name
}

output "backend_service_name" {
  value = aws_ecs_service.this.name
}

output "backend_task_family" {
  value = aws_ecs_task_definition.this.family
}
output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.this.family
}
output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}