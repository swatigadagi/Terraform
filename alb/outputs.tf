output "listener_arn" {
  value = aws_lb_listener.https.arn
}
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_backend_arn" {
  value = aws_lb_target_group.backend.arn
}

output "target_group_worker_arn" {
  value = aws_lb_target_group.worker.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.backend.arn
}
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
output "alb_zone_id" {
  value = aws_lb.this.zone_id
}
