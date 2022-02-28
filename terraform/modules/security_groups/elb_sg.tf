# Security group for elb subnet resources
resource "aws_security_group" "elb_sg" {
  name   = "elb-sg"
  vpc_id = var.vpc_id
  
  tags = merge({"Name"       = "tf-voting-app-102062981000"
                Name = "elb-sg-${var.environment}"
                "kubernetes.io/cluster/${var.cluster_name}" = "owned"
                "Managed_by" = "terraform"
                },var.default_tags)
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "elb_ingress_elb_80" {
  description = "Allow all incoming traffic to port 80"
  security_group_id = aws_security_group.elb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_ingress_elb_443" {
  description = "Allow all incoming traffic to port 80"
  security_group_id = aws_security_group.elb_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

## Egress rule
resource "aws_security_group_rule" "sg_egress_elb" {
  security_group_id = aws_security_group.elb_sg.id
  type              = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}