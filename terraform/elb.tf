#Ideally this should be fully managed by ingress controller in k8s cluster


resource "aws_lb" "elb" {
  name               = "voting-app-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_groups.elb_sg_id]
  subnets            = [ module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2] ]
  enable_deletion_protection = false
  idle_timeout       = 60
  
#   access_logs {
#     bucket  = "elb-logging"
#     prefix  = "cluster_name"
#     enabled = true
#   }
  # enable_deletion_protection = true
  drop_invalid_header_fields = true
  tags = merge(var.default_tags, {
    Name = "voting-app-elb"
  }
  )
}
resource "aws_lb_listener" "voting-app-listener_80" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"
#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_tg_1.arn
  }
}
# resource "aws_lb_listener" "elb_listener_2" {
#   load_balancer_arn = aws_lb.elb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
#   certificate_arn   = "arn:aws:acm:eu-west-1:366511911860:certificate/cert-here"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.elb_tg_1.arn
#   }
# }
#target group setup
resource "aws_lb_target_group" "elb_tg_1" {
  name                  = "tf-voting-app-tg"
  port                  = 5000
  protocol              = "HTTP"
  vpc_id                = module.vpc.vpc_id
  deregistration_delay  = 20
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    path                = "/"
    interval            = 30
    port                = 5000
    protocol            = "HTTP"
    matcher             = 200
  }
}

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.test.arn
#   target_id        = aws_instance.test.id
#   port             = 80
# }

