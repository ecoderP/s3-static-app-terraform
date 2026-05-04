resource "aws_s3_bucket" "tf_state" {
  bucket = "my-terraform-state-bucket"

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-locks"
  billing_mode = "PROVISIONED"
  read_capacity = 25
  write_capacity = 25
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}