data "aws_ami" "openSUSE" {
  most_recent = true

  filter {
    name   = "name"
    values = ["openSUSE-Leap-15.3-HVM-x86_64-Innovators-5e60433b-bd08-44d8-be9e-2b774638fa6c"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_launch_template" "launch_template" {
  name_prefix   = var.name_prefix
  image_id      = data.aws_ami.openSUSE.id
  instance_type = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids

  user_data = filebase64("${path.module}/${var.user_data}")
  key_name = var.key_name 

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  monitoring {
    enabled = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 1
    # instance_metadata_tags      = "enabled" #bug - cannot be enabled with kubernetes tagging
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      "Name" = var.launch_template_tag
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      volume_size = 150
    }
  }
  #   tags = merge({
  #     Name = var.launch_template_tag
  #     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  #   },var.default_tags)
  # }
}

resource "aws_autoscaling_group" "asg" {
  # availability_zones = ["us-east-1a"]
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "InstanceType"
    value               = var.asg_tag
    propagate_at_launch = true
  }
  tag {
    key                 = "Talent"
    value               = "102062981000"
    propagate_at_launch = true
  }
}
