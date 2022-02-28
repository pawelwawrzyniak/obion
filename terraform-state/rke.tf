#below was added here so we could preserve logs and rke data files outside of terraform lifetime
#ideally storage for secrets should be changed to secrets manager or parameter store
# Logging
resource "aws_s3_bucket" "rke-logging" {
  bucket = "rke-logging-102062981000"
  # acl    = "log-delivery-write"
  tags = merge({"Name" = "rke-logging-102062981000"
                "Project" = "DevSecOps"
                },var.default_tags)
  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm     = "AES256"
  #     }
  #   }
  # }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rke-s3-logging-encrypt" {
  bucket = aws_s3_bucket.rke-logging.bucket

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = "aws/s3"
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "rke-s3-logging-acl" {
  bucket = aws_s3_bucket.rke-logging.bucket
  acl    = "log-delivery-write"
}

# data "aws_s3_bucket" "selected" {
#   bucket = "rke-logging-102062981000"
# }

resource "aws_s3_bucket" "rke-data" {
    bucket = "rke-data-102062981000"

    tags = merge({"Name" = "rke-data-102062981000"
                "Project" = "DevSecOps"
                },var.default_tags)
    # logging {
    #   target_bucket = data.aws_s3_bucket.selected.id
    #   target_prefix = "rke-data/"
    # }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rke-s3-encrypt" {
  bucket = aws_s3_bucket.rke-data.bucket

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = "aws/s3"
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "rke-s3-data-acl" {
  bucket = aws_s3_bucket.rke-data.bucket
  acl    = "private"
}

resource "aws_s3_bucket_logging" "rke-data-logging" {
  bucket = aws_s3_bucket.rke-data.id

  target_bucket = aws_s3_bucket.rke-logging.id
  target_prefix = "rke-data/"
}

# ssm