data aws_ecs_cluster default {
  cluster_name = var.cluster_name
}


resource aws_ecs_service django {
  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }

  name                               = "${var.prefix}"
  cluster                            = data.aws_ecs_cluster.default.id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"
  task_definition                    = var.task_definition_arn
  desired_count                      = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids

    # if you have NAT, set to false
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.django.id
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }
}
