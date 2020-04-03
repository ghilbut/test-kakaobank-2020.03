data aws_lb alb {
  name = var.alb_name
}


resource aws_lb_target_group django {
  name        = "alb-${var.prefix}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  #health_check {
  #  enabled = false
  #}
}


resource aws_lb_listener_rule django {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_route_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django.arn
  }

  condition {
    host_header {
      values = [
        var.alb_route_host,
      ]
    }
  }
}
