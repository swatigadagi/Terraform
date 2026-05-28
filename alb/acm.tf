resource "aws_acm_certificate" "this" {
  domain_name       = "${var.project}.example.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
