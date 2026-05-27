# IAM Role for Worker
resource "aws_iam_role" "worker_role" {
  name = "${var.project}-${var.environment}-worker-role-${substr(md5(timestamp()),0,6)}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

# Attach SSM Policy to Worker Role
resource "aws_iam_role_policy_attachment" "worker_ssm_attachment" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.project}-${var.environment}-worker-profile-${substr(md5(timestamp()),0,6)}"
  role = aws_iam_role.worker_role.name
}
