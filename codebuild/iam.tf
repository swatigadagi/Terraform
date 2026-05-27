# ECS Access
resource "aws_iam_role_policy_attachment" "ecs_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# ECR Access
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# EC2 & VPC Access
resource "aws_iam_role_policy_attachment" "ec2_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# RDS Access
resource "aws_iam_role_policy_attachment" "rds_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Load Balancer Access
resource "aws_iam_role_policy_attachment" "alb_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# S3 Access
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Access
resource "aws_iam_role_policy_attachment" "iam_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# SSM Parameter Store Access
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# CloudWatch Logs Access
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# CodeBuild Access
resource "aws_iam_role_policy_attachment" "codebuild_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}
