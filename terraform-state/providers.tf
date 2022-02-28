terraform {
    required_version = "~> 1.1.6"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.2.0"
      }
    }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.region
  # assume_role {
  #   role_arn     = "arn:aws:iam::130575395405:role/talent_role"
  #   # role_arn     = var.role_arn
  # }
}
