output "distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}

output "bucket_name" {
  value = module.s3_static_site.bucket_name
}

output "github_actions_role_arn" {
  value = module.github_oidc.github_actions_role_arn
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}