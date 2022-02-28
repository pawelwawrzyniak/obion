# # data "aws_ami" "openSUSE" {
# #   most_recent = true

# #   filter {
# #     name   = "name"
# #     values = ["openSUSE-Leap-15-3-v20200702-hvm-ssd-x86_64-*"]
# #     # values = ["openSUSE-Leap-15.3-HVM-x86_64-Innovators-5e60433b-bd08-44d8-be9e-2b774638fa6c"]
# #   }

# #   filter {
# #     name   = "virtualization-type"
# #     values = ["hvm"]
# #   }

# #   owners = ["679593333241"]
# # }

# data "aws_ami" "ubuntu" {
#     most_recent = true
#     filter {
#         name   = "name"
#         values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#     }
#     filter {
#         name   = "virtualization-type"
#         values = ["hvm"]
#     }
#     owners = ["099720109477"] # Canonical
# }

# # EC2 Auto Scaling Group - Launch Template
# # resource "aws_launch_template" "launch_template" {
# #   name_prefix   = var.name_prefix
# #   image_id      = data.aws_ami.ubuntu.id
# #   instance_type = var.instance_type

# #   vpc_security_group_ids = var.vpc_security_group_ids

# #   user_data = filebase64("${path.module}/${var.user_data}")
# #   key_name = var.key_name 

# #   iam_instance_profile {
# #     arn = aws_iam_instance_profile.instance_profile.arn
# #   }

# #   monitoring {
# #     enabled = true
# #   }

# #   tag_specifications {
# #     resource_type = "instance"

# #     tags = merge({
# #       Name = var.launch_template_tag
# #       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
# #     },var.default_tags)
# #   }
# # }

# # # EC2 Auto Scaling Group Control Plane
# # resource "aws_autoscaling_group" "asg" {
# #   # availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
# #   availability_zones = var.availability_zones
# #   desired_capacity   = var.desired_capacity
# #   max_size           = var.max_size
# #   min_size           = var.min_size
# #   force_delete       = true
# #   # vpc_zone_identifier = ["us-east-1a", "us-east-1b", "us-east-1c"]
# #   # vpc_zone_identifier = var.private_subnet_ids
# #   # target_group_arns = [var.target_group_arn]
# #   launch_template {
# #     id      = aws_launch_template.launch_template.id
# #     version      = aws_launch_template.launch_template.latest_version
# #     # version = "$Latest"
# #   }

# #   tag {
# #     key                 = "InstanceType"
# #     value               = var.asg_tag
# #     propagate_at_launch = true
# #   }
# #   tag {
# #     key                 = "Talent"
# #     value               = "102062981000"
# #     propagate_at_launch = true
# #   }
# # }

# ## test ASG creation
# resource "aws_launch_template" "launch_template" {
#   name_prefix   = var.name_prefix
#   image_id      = data.aws_ami.ubuntu.id
#   instance_type = var.instance_type
#   vpc_security_group_ids = var.vpc_security_group_ids
#   # vpc_security_group_ids = ["sg-12345678"]

#   user_data = filebase64("${path.module}/${var.user_data}")
#   key_name = var.key_name 

#   iam_instance_profile {
#     arn = aws_iam_instance_profile.instance_profile.arn
#   }

#   monitoring {
#     enabled = true
#   }
#   metadata_options {
#     http_endpoint               = "enabled"
#     # http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#     # instance_metadata_tags      = "enabled"
#   }

#   tag_specifications {
#     resource_type = "instance"

#   #   tags = {
#   #     "Name" = var.launch_template_tag
#   #     "kubernetes.io/cluster/test" = "owned"
#   #   }
#   # }
#     tags = {
#       "Name" = var.launch_template_tag
#       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#     }
#   }

#   block_device_mappings {
#     device_name = "/dev/sda1"
#     ebs {
#       delete_on_termination = true
#       encrypted = true
#       volume_size = 150
#     }
#   }
#   #   tags = merge({
#   #     Name = var.launch_template_tag
#   #     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   #   },var.default_tags)
#   # }
# }

# resource "aws_autoscaling_group" "asg" {
#   # availability_zones = ["us-east-1a"]
#   # availability_zones = var.availability_zones
#   desired_capacity   = var.desired_capacity
#   max_size           = var.max_size
#   min_size           = var.min_size
#   vpc_zone_identifier = var.vpc_zone_identifier
#   # vpc_zone_identifier = [aws_subnet.example1.id, aws_subnet.example2.id]

#   launch_template {
#     id      = aws_launch_template.launch_template.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "InstanceType"
#     value               = var.asg_tag
#     propagate_at_launch = true
#   }
#   tag {
#     key                 = "Talent"
#     value               = "102062981000"
#     propagate_at_launch = true
#   }
# }

# # ##added
# # ##launch config
# # resource "aws_launch_configuration" "tech_asg_conf" {
# #   name_prefix   = var.full_cluster_name
# #   image_id      = data.aws_ami.ubuntu.id
# #   instance_type = var.instance_type
# #   user_data     = file("modules/network/scripts/init_${var.env}.sh")
# #   security_groups = [aws_security_group.tech_nodes_sg_1.id]
# #   iam_instance_profile = "arn:aws:iam::366511911860:instance-profile/cvtr-aws-fullaccess"
# #   key_name      = "tech_2021"
# #   lifecycle {
# #     create_before_destroy = true
# #   }
# # }
# # ##auto scaling group
# # resource "aws_autoscaling_group" "tech_asg_group" {
# #   name                 = var.full_cluster_name
# #   launch_configuration = aws_launch_configuration.tech_asg_conf.name
# #   min_size             = 1
# #   desired_capacity     = 1
# #   max_size             = 2
# #   vpc_zone_identifier  = [aws_subnet.sbn_private[0].id, aws_subnet.sbn_private[1].id]
# #   target_group_arns    = [aws_lb_target_group.tech_elb_tg_1.arn]
# #   health_check_grace_period = 15
# #   default_cooldown          = 15
# #   tags = concat(
# #     [
# #       {
# #         "key"                 = "Name"
# #         "value"               = "${var.full_cluster_name}-${random_id.server.hex}"
# #         "propagate_at_launch" = true
# #       },
# #     ],
# #   )
# #   lifecycle {
# #     create_before_destroy = true
# #   }
# #   depends_on = [ aws_lb.tech_elb ]
# # }