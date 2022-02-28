# Security group for control plane
resource "aws_security_group" "control_plane_sg" {
  name   = "k8s-control-plane-sg"
  vpc_id = var.vpc_id

  tags =  merge({
                Name = "k8s-control-plane-sg-${var.environment}"
                "kubernetes.io/cluster/${var.cluster_name}" = "owned"
                },var.default_tags)
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol          = "tcp"
  cidr_blocks = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
}

resource "aws_security_group_rule" "control_plane_inbound_self" {
  description = "Allow RKE for deployment selfchecks"
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol          = "tcp"
  self = true
  # cidr_blocks = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
}

resource "aws_security_group_rule" "control_nodes_inbound_ssh" {
  description = "Allow worker nodes to allow bastion ssh connections."
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port   = 22
  to_port     = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  # source_security_group_id = aws_security_group.public_sg.id
}

resource "aws_security_group_rule" "control_plane_inbound_443" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "control_plane_inbound_80" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.elb_sg.id
}

## Egress rule
resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}