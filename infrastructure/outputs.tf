output "cloudfront_url" {
  value = aws_cloudfront_distribution.site_cdn.domain_name
}