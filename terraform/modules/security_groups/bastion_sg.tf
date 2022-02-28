# Security group for public subnet resources
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id
  
  tags = merge({"Name"       = "bastion-sg-102062981000"
                "Managed_by" = "terraform"
                "kubernetes.io/cluster/${var.cluster_name}" = "owned"
                },var.default_tags)
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "bastion_ingress_public_22" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["176.249.48.23/32"] #ideally VPN connection at the front of it
}

## Egress rule
resource "aws_security_group_rule" "bastion_egress_public" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}