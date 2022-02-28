variable "region" {
    description   = "aws region for TF deployment"
    type          = string
    default       = "us-east-1"
}

variable "aws_profile" {
  description   = "aws profile to be used for tf deployment"
  type          = string
  default       = "obion"
}

variable "role_arn" {
  default = "arn:aws:iam::130575395405:role/talent_role"
}

variable "default_tags" {
    description = "Default tags to assign to all resources"
    type        = map
    default     = {
      Environment: "devops",
      Talent: "102062981000"
    }
}

variable "create_vpc" {
  default = true
}
variable "enable_flow_log" {
  default = false
}
variable "environment" {
  default = "devops"
}
variable "key_name" {
  default = "voting_app"
}
variable "cluster_name" {
  default = "rke-voting-app"
}
