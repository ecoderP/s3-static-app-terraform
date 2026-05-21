variable "bucket_name" {
  type = string
}

variable "s3_server_side_encryption_algo" {
  description = "Encryption algorithm for S3 server side buckets"
  type        = string
  default     = "AES256"
}

variable "environment" {
  type = string
}