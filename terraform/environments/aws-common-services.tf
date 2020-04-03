################################################################
##
##  Route 53
##

data aws_route53_zone public {
  name         = var.domain_name
  private_zone = false
}



################################################################
##
##  AWS Certificate Manager
##

resource aws_acm_certificate www {
  provider = aws.acm_certificate

  domain_name       = local.web_domain
  validation_method = "DNS"

  tags = merge(
    map(
      "Name", local.web_domain,
    ),
    local.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_acm_certificate api {
  provider = aws.acm_certificate

  domain_name       = local.api_domain
  validation_method = "DNS"

  tags = merge(
    map(
      "Name", "${local.api_domain}",
    ),
    local.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  acm_validation_options = [
    aws_acm_certificate.www.domain_validation_options,
    aws_acm_certificate.api.domain_validation_options,
  ]
}

resource aws_route53_record aws_acm_certificate {
  count = length(local.acm_validation_options)

  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.acm_validation_options.*.0.resource_record_name[count.index]
  type    = local.acm_validation_options.*.0.resource_record_type[count.index]
  ttl     = 5

  records = [
    local.acm_validation_options.*.0.resource_record_value[count.index],
  ]
}



################################################################
##
##  AWS VPC
##

data aws_vpc default {
  default = true
}

data aws_subnet defaults {
  count = length(local.az_suffixes)

  availability_zone = "${var.aws_region}${local.az_suffixes[count.index]}"
  default_for_az = true
  vpc_id = data.aws_vpc.default.id
}

data aws_subnet default {
  availability_zone = "${var.aws_region}${local.az_suffixes[0]}"
  default_for_az = true
  vpc_id = data.aws_vpc.default.id
}


resource aws_security_group www {
  name        = "${var.srv_name}-www"
  description = "Allow all traffic"
  vpc_id      = data.aws_vpc.default.id

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
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(
    map(
      "Name", "sg-${var.srv_name}-www",
    ),
    local.tags, 
  )
}



################################################################
##
##  AWS LB
##

resource aws_lb alb {
  name               = "alb-${var.srv_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.www.id]
  subnets            = data.aws_subnet.defaults.*.id

  tags = merge(
    map(
      "Name",  "alb-${var.srv_name}",
    ),
    local.tags, 
  )
}

resource aws_lb_listener http {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (AWS Application Load Balancer)"
      status_code  = "404"
    }
  }
}



################################################################
##
##  AWS ECS Fargate
##

resource aws_ecs_cluster default {
  name               = "${var.srv_name}"
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    map(
      "Name", "${var.srv_name}"
    ),
    local.tags
  )
}
