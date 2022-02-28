data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  create_vpc = var.create_vpc
  # enable_flow_log = var.enable_flow_log
  # create_flow_log_cloudwatch_iam_role = true
  # create_flow_log_cloudwatch_log_group = true
  # flow_log_destination_type = "cloud-watch-logs"

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  name = "vpc-102062981000"
  cidr = "10.0.0.0/16"

  azs                 = data.aws_availability_zones.available.zone_ids
  # azs               = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets    = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

  
  create_igw = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway  = false

  # RKE requirements
  enable_dns_hostnames = true
  enable_dns_support = true

  # ACL SETUP
  # manage_default_network_acl = true
  # public_dedicated_network_acl = true
  # public_inbound_acl_rules = 
  # public_outbound_acl_rules = 

  tags = merge({"Name"       = "tf-voting-app-102062981000"
                "Managed_by" = "terraform"
                },var.default_tags)
}

module "security_groups" {
  depends_on = [
    module.vpc
  ]
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  environment = var.environment
  default_tags = var.default_tags
  cluster_name = var.cluster_name
  private_subnet_cidr_blocks = [ module.vpc.private_subnets_cidr_blocks[0], module.vpc.private_subnets_cidr_blocks[1], module.vpc.private_subnets_cidr_blocks[2]]
  # private_subnet_cidr_blocks = [ module.vpc.private_subnets_cidr_blocks[*] ]
  public_subnet_cidr_blocks = [ module.vpc.public_subnets_cidr_blocks[0], module.vpc.public_subnets_cidr_blocks[1], module.vpc.public_subnets_cidr_blocks[2]]
}

module "control_plane" {
  depends_on = [
    module.vpc
  ]
  source = "./modules/control_plane"

  vpc_id = module.vpc.vpc_id
  availability_zones = data.aws_availability_zones.available.names

  cluster_name = var.cluster_name
  name_prefix = "rke-control-voting-app"
  
  launch_template_tag = "rke-control-voting-app-lt"
  asg_tag = "rke-control-voting-app-asg"
  default_tags = var.default_tags
  
  instance_type = "t3.medium"
  instance_profile_name = "rke_control_plane_profile"
  private_subnet_ids = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2] ]
  public_subnet_ids = []
  vpc_security_group_ids = [
    module.security_groups.control_plane_sg_id,
  ]
  vpc_zone_identifier = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2] ]
  environment = var.environment
  desired_capacity = 3
  max_size = 10
  min_size = 3
  user_data = "master_userdata.sh"
  # key_name = aws_key_pair.generated_key.key_name
  key_name = var.key_name
}

module "worker_nodes" {
  depends_on = [
    module.vpc,
    module.control_plane
  ]
  source = "./modules/worker_nodes"

  vpc_id = module.vpc.vpc_id
  availability_zones = data.aws_availability_zones.available.names

  cluster_name = var.cluster_name
  name_prefix = "rke-worker-voting-app"
  
  launch_template_tag = "rke-worker-voting-app-lt"
  asg_tag = "rke-worker-voting-app-asg"
  default_tags = var.default_tags
  
  instance_type = "t3.large"
  instance_profile_name = "rke_worker_nodes_profile"
  private_subnet_ids = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2] ]
  public_subnet_ids = []
  vpc_security_group_ids = [
    module.security_groups.worker_nodes_sg_id,
  ]
  vpc_zone_identifier = [ module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2] ]
  environment = var.environment
  desired_capacity = 3
  max_size = 10
  min_size = 3
  user_data = "worker_userdata.sh"
  key_name = var.key_name
}

module "bastion" {
  depends_on = [
    module.vpc
  ]
  source = "./modules/bastion"

  vpc_id = module.vpc.vpc_id
  availability_zones = data.aws_availability_zones.available.names

  cluster_name = var.cluster_name
  name_prefix = "rke-bastion-voting-app"
  
  launch_template_tag = "rke-bastion-voting-app-lt"
  asg_tag = "rke-bastion-voting-app-asg"
  default_tags = var.default_tags
  
  instance_type = "t2.micro"
  instance_profile_name = "rke_bastion_nodes_profile"
  private_subnet_ids = []
  public_subnet_ids = [ module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2] ]
  vpc_security_group_ids = [
    module.security_groups.bastion_sg_id,
  ]
  vpc_zone_identifier = [ module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2] ]
  environment = var.environment
  desired_capacity = 1
  max_size = 10
  min_size = 1
  user_data = "bastion_userdata.sh"
  # key_name = aws_key_pair.generated_key.key_name
  key_name = var.key_name
}

# module "efs" { 
#   WIP -> could be useful if DB is sitting in the cluster and not RDS instances
#   source              = "./modules/efs"
#   name   = local.name
#   vpc_id              = 
#   private_subnets     = var.private_subnets
#   tags                = var.default_tags
# }