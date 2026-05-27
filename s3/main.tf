resource "aws_s3_bucket" "this" {
bucket = "${lower(var.project)}-${lower(var.environment)}-frontend"
  tags = {
  Name        = "${var.project}-${var.environment}-frontend"  
  Project     = var.project
  Environment = var.environment
}
}
# Block ALL public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
