variable "vpc_id" {}

variable "environment" {}

# variable private_subnet_ids {
#   type        = list(string)
#   description = "Private subnet IDs"
# }

# variable "public_subnet_ids" {
#   type = list(string)
#   description = "Private subnet IDs"
# }

# variable security_group_ids {
#   type        = list(string)
#   description = "Launch template SGs"
# }

# /* variable "target_group_arn" {
#   type        = string
#   description = "List of target groups"
# } */

# variable "cluster_name" {
#   description = "The name of the cluster"
#   type = string
# }

# variable "key_name" {
#   type = string
# }

variable "default_tags" {}
variable "cluster_name" {
  description = "The name of the cluster"
  type = string
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  # default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "CIDR block range for the private subnet"
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  # default     = ["10.0.2.0/24", "10.0.3.0/24"]
  description = "CIDR block range for the public subnet"
}