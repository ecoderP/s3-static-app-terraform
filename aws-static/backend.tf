terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PROVISIONED"
  read_capacity = 25
  write_capacity = 25
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}