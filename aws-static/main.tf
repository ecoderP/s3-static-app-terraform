resource "aws_s3_bucket" "site_bucket" {
  bucket = var.bucket_name
}

# Make s3 public private - no public access - secure by default
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.site_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# upload website files
resource "aws_s3_object" "website_files" {
  for_each = fileset("../dist", "**/*")

  bucket = aws_s3_bucket.site_bucket.id
  key    = each.value
  source = "../dist/${each.value}"

  etag = filemd5("../dist/${each.value}")

  # Content mapping
  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "json" = "application/json"
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "svg"  = "image/svg+xml"
      "jpeg" = "image/jpeg"
      "ico"  = "image/x-icon"
      "webp" = "image/webp"
      "map"  = "application/json"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )

  tags = {
    Project = var.project_name
    Env     = "dev"
  }
}

# Orgin access
resource "aws_cloudfront_origin_access_control" "site_oac" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "site_cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.site_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS Managed CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}

# Cache invalidation
action "aws_cloudfront_create_invalidation" "site_cache" {
  config {
    distribution_id = aws_cloudfront_distribution.site_cdn.id
    paths           = ["/*"]
  }
}

resource "terraform_data" "example" {
  input = "trigger-invalidation"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.site_cache]
    }
  }
}

# S3 bucket policy allowing cloudfront access to S3
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.site_bucket.id

  depends_on = [aws_cloudfront_distribution.site_cdn]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site_cdn.arn
          }
        }
      }
    ]
  })
}