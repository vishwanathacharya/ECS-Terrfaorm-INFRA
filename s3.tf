# S3 Bucket for Media Files
resource "aws_s3_bucket" "media_files" {
  bucket = "${local.name_prefix}-media-files"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-media-files"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "media_files" {
  bucket = aws_s3_bucket.media_files.id
  versioning_configuration {
    status = var.environment == "production" ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "media_files" {
  bucket = aws_s3_bucket.media_files.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for CloudFront
resource "aws_s3_bucket_policy" "media_files" {
  bucket = aws_s3_bucket.media_files.id
  depends_on = [aws_s3_bucket_public_access_block.media_files]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.media_files.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.media_files.arn}/*"
      }
    ]
  })
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "media_files" {
  bucket = aws_s3_bucket.media_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "media_files" {
  bucket = aws_s3_bucket.media_files.id

  rule {
    id     = "media_lifecycle"
    status = "Enabled"
    
    # Add required filter
    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.environment == "production" ? 2555 : 365  # 7 years for prod, 1 year for dev/staging
    }
  }
}
