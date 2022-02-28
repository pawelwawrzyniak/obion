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

# resource "aws_s3_bucket_server_side_encryption_configuration" "rke-s3-encrypt" {
#   bucket = aws_s3_bucket.rke-data.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       # kms_master_key_id = "aws/s3"
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_acl" "rke-s3-data-acl" {
#   bucket = aws_s3_bucket.rke-data.bucket
#   acl    = "private"
# }

# resource "aws_s3_bucket_logging" "rke-data-logging" {
#   bucket = aws_s3_bucket.rke-data.id

#   target_bucket = data.aws_s3_bucket.selected.id
#   target_prefix = "rke-data/"
# }

# # ssm