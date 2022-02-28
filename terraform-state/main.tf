resource "aws_s3_bucket" "terraform_state" {
    bucket = "tf-state-102062981000"

    tags = merge({ "Name" = "tf-state-102062981000"
                },var.default_tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.bucket
    rule {
    apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}

# resource "aws_s3_bucket_logging" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   target_bucket = "tf-state-102062981000-logging"
#   target_prefix = "tf-state-102062981000/"
# }

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
    bucket                  = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf-lock-voting-app" {
  name         = "tf_lock_voting_app"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  point_in_time_recovery {
    enabled = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = merge({ "Name" = "tf-lock-voting-app-102062981000"
                },var.default_tags)
}
