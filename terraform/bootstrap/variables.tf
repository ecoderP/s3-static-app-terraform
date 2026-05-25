variable "aws_region" {
  type = string
}

variable "backend_bucket_name" {
  description = "Base name for the S3 bucket to store Terraform state. A random suffix will be added to ensure uniqueness."
  type        = string
}


variable "project_name" {
  description = "Name of the project for tagging and resource naming"
  type        = string
}

variable "s3_encryption_algorithm" {
  description = "Encryption algorithm for S3 buckets"
  type        = string
}
