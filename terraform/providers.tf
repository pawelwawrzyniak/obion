terraform {
    required_version = "~> 1.1.6"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.region
  assume_role {
    #watchout hardcoded aws account ID
    role_arn     = "arn:aws:iam::130575395405:role/talent_role"
  }
}


terraform {
  backend "s3" {
    # # role_arn     = "arn:aws:iam::130575395405:role/talent_role"
    bucket  = "tf-state-102062981000"
    dynamodb_table = "tf_lock_voting_app"
    key     = "tf/us-east-1/app/voting-app.tfstate"
    region  = "us-east-1"
    profile = "obion"
  }
}
