################################################################
##
##  Scaling ECS Service
##

resource aws_appautoscaling_target scale_target {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.django.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = 4
  min_capacity       = 1
}



##--------------------------------------------------------------
##  Scale Out

resource aws_appautoscaling_policy scale_out {
  name               = "scale-out"
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}


resource aws_cloudwatch_metric_alarm cpu_utilization_high {
  alarm_name          = "${var.prefix}-CPU-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 80  # percent

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.django.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.scale_out.arn,
  ]
}



##--------------------------------------------------------------
##  Scale In

resource aws_appautoscaling_policy scale_in {
  name               = "scale-in"
  resource_id        = aws_appautoscaling_target.scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scale_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scale_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}


resource aws_cloudwatch_metric_alarm cpu_utilization_low {
  alarm_name          = "${var.prefix}-CPU-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 30  # percent

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.django.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.scale_in.arn,
  ]
}
