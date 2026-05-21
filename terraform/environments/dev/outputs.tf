output "cloudfront_url" {
  value = module.cloudfront.cloudfront_url
}

output "bucket_name" {
  value = module.s3_static_site.bucket_name
}