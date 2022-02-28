# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=3.5.0".
# Note the extra `/` after the protocol is required for the shorthand
# notation.
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.12.0"
}

# Indicate what region to deploy the resources into
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF

  provider "aws" {
    profile = "obion"
    region = "us-east-1"
    assume_role {
        role_arn     = "arn:aws:iam::130575395405:role/talent_role"
    }
  }

  terraform {
    required_version = "~> 1.1.6"
    backend "s3" {}
  }
  EOF
}

remote_state {
  backend = "s3" 
  config = {
    encrypt = true
    # role_arn     = "arn:aws:iam::130575395405:role/talent_role"
    bucket  = "tf-state-102062981000"
    dynamodb_table = "tf_lock_voting_app"
    key     = "tf/us-east-1/app/voting-app.tfstate"
    region  = "us-east-1"
    profile = "obion"
  }
}
#   profile = var.aws_profile
#   region  = var.region
#   assume_role {
#     #watchout hardcoded aws account ID
#     role_arn     = "arn:aws:iam::130575395405:role/talent_role"
#   }

# Indicate the input values to use for the variables of the module.
inputs = {
  # VPC MODULE
  create_vpc = true
  # enable_flow_log = false

  name = "vpc-102062981000"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  # create_vpn = false


  # COMMON
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}