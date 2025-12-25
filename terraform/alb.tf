# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-tasks-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false

  tags = merge(local.default_tags, {
    Name = "${var.app_name}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

# Effective domain name: use provided var.domain_name when set, otherwise fall back to the ALB DNS name
locals {
  effective_domain_name = length(trimspace(var.domain_name)) > 0 ? var.domain_name : aws_lb.main.dns_name
}

# Optionally import a certificate into ACM if local PEM paths are provided
resource "aws_acm_certificate" "imported" {
  count = length(trimspace(var.certificate_body_path)) > 0 ? 1 : 0

  private_key      = file(var.private_key_path)
  certificate_body = file(var.certificate_body_path)

  certificate_chain = length(trimspace(var.certificate_chain_path)) > 0 ? file(var.certificate_chain_path) : null

  # Use the effective domain name
  domain_name = local.effective_domain_name

  lifecycle {
    create_before_destroy = true
  }
}

# ALB HTTPS Listener (uses imported ACM cert when present)
resource "aws_lb_listener" "https" {
  count             = length(aws_acm_certificate.imported) > 0 ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.imported[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# When a certificate is provided, create an HTTP listener that redirects to HTTPS
resource "aws_lb_listener" "http_redirect" {
  count             = length(aws_acm_certificate.imported) > 0 ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# When no certificate is provided, create an HTTP listener that forwards to the target group
resource "aws_lb_listener" "http" {
  count             = length(aws_acm_certificate.imported) > 0 ? 0 : 1
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "imported_certificate_arn" {
  description = "ARN of the imported ACM certificate (if created)"
  value       = length(aws_acm_certificate.imported) > 0 ? aws_acm_certificate.imported[0].arn : ""
}

output "effective_domain_name" {
  description = "Domain name used for the certificate (either var.domain_name or ALB DNS)"
  value       = local.effective_domain_name
}
