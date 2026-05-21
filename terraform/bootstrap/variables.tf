variable "aws_region" {
  type = string
}

variable "state_bucket_name" {
  description = "Base name for the S3 bucket to store Terraform state. A random suffix will be added to ensure uniqueness."
  type        = string
}
/* ==
variable "enable_deletion_control" {
  description = "Enable deletion control to prevent accidental deletion of critical resources"
  type        = bool
  default     = true
}
== */

variable "s3_encryption_algo" {
  description = "Encryption algorithm for S3 buckets"
  type        = string
}

variable "dynamodb_table_name" {
  type = string
}