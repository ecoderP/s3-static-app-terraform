module "s3_static_site" {
  source = "../../modules/s3-static-site"

  bucket_name = var.website_bucket_name

  environment = var.environment
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name                = var.project_name
  environment                 = var.environment
  bucket_name                 = module.s3_static_site.bucket_name
  bucket_arn                  = module.s3_static_site.bucket_arn
  bucket_regional_domain_name = module.s3_static_site.bucket_regional_domain_name
}

module "github_oidc" {
  source = "../../modules/iam-github-oidc"

  project_name = var.project_name
  environment  = var.environment

  github_repo   = var.github_repo
  github_branch = var.github_branch

  bucket_arn                  = module.s3_static_site.bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}