################################################################
##
##  AWS CloudWatch
##

resource aws_cloudwatch_log_group django_cron {
  name              = "${var.srv_name}-django-cron"
  retention_in_days = 1

  tags = merge(
    map(
      "Name", "${var.srv_name}-django-cron",
    ),
    local.tags
  )
}



################################################################
##
##  AWS Secret Manager
##

resource aws_secretsmanager_secret open_api_key {
  name = "${var.srv_name}-open-api-key"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version open_api_key {
  secret_id     = aws_secretsmanager_secret.open_api_key.id
  secret_string = var.open_api_key
}



################################################################
##
##  AWS ECS
##

##--------------------------------------------------------------
##  local variables

locals {
  django_cron_family = "${var.srv_name}-django-cron"
}

##--------------------------------------------------------------
##  templates

data template_file django_cron_container {
  template = <<EOF
[
  {
    "name": "${local.django_container_name}",
    "image": "${aws_ecr_repository.django.repository_url}:latest",
    "essential": true,
    "environment": ${jsonencode(local.environment)},
    "secrets": ${jsonencode(
      concat(
        local.secrets,
        [
          {
            "name": "OPEN_API_KEY",
            "valueFrom": "${aws_secretsmanager_secret.open_api_key.arn}"
          }
        ]
      )
    )},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region":          "${var.aws_region}",
        "awslogs-group":           "${aws_cloudwatch_log_group.django_cron.name}",
        "awslogs-stream-prefix":   "${var.srv_name}",
        "awslogs-datetime-format": "\\[%Y-%m-%d %H:%M:%S\\]"
      }
    }
  }
]
EOF
}

data template_file django_cron_task {
  template = <<EOF
{
  "family": "${local.django_cron_family}",
  "executionRoleArn": "${local.execution_role}",
  "networkMode": "awsvpc",
  "containerDefinitions": ${data.template_file.django_cron_container.rendered},
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "${local.django_cpu}",
  "memory": "${local.django_memory}",
  "tags": ${jsonencode([for name, value in merge(
        map("Name", "${var.srv_name}-django-cron"),
        local.tags
      ): {
        key = name
        value = value
      }
    ])
  }
}
EOF
}

resource local_file django_cron_task_definition {
  sensitive_content = data.template_file.django_cron_task.rendered
  filename = "${path.module}/../../django/ecs/django-cron-task-definition.json"
}

##--------------------------------------------------------------
##  task definition

resource aws_ecs_task_definition django_cron {
  family                   = local.django_cron_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.django_cpu
  memory                   = local.django_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  # defined in role.tf
  #task_role_arn = aws_iam_role.app_role.arn

  container_definitions    = data.template_file.django_cron_container.rendered

  tags = merge(
    map(
      "Name", "${var.srv_name}-django-cron"
    ),
    local.tags
  )
}



################################################################
##
##  AWS IAM
##

data aws_iam_policy_document django_cron {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "events.amazonaws.com",
      ]
    }
  }
}

resource aws_iam_role django_cron {
  name = "django_cron"
  assume_role_policy = data.aws_iam_policy_document.django_cron.json
}

resource aws_iam_role_policy_attachment django_cron {
  role       = aws_iam_role.django_cron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource aws_iam_role_policy django_cron {
  name = "django_cron"
  role = aws_iam_role.django_cron.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(aws_ecs_task_definition.django_cron.arn, "/:\\d+$/", ":*")}"
        }
    ]
}
EOF
}



################################################################
##
##  AWS CloudWatch Event
##

resource aws_cloudwatch_event_rule django_cron {
  name        = "${var.srv_name}-django-cron"
  description = "Crawling seoul public parking lots' information"
  schedule_expression = "cron(0 17 * * ? *)"  # every 10 minutes
}

resource aws_cloudwatch_event_target django_cron {
  target_id = "${var.srv_name}-django-cron"
  arn       = aws_ecs_cluster.default.arn
  rule      = aws_cloudwatch_event_rule.django_cron.name
  role_arn  = aws_iam_role.django_cron.arn

  ecs_target {
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [data.aws_subnet.default.id]
      security_groups  = [aws_security_group.django.id]
      assign_public_ip = true
    }
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.django_cron.arn
  }

  input = <<EOF
{
  "containerOverrides": [
    {
      "name": "${local.django_container_name}",
      "command": ["./manage.py", "crawling"]
    }
  ]
}
EOF
}
