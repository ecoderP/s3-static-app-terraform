output "distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}

output "bucket_name" {
  value = module.s3_static_site.bucket_name
}