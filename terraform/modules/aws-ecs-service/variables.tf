variable prefix {
  type = string
}


variable vpc_id {
  type = string
}

variable subnet_ids {
  type = list(string)
}

variable security_group_ids {
  type = list(string)
}


variable alb_name {
  type = string
}

variable alb_listener_arn {
  type = string
}

variable alb_route_host {
  type = string
}

variable alb_route_priority {
  type = number
}


variable cluster_name {
  type = string
}


variable container_name {
  type = string
}

variable container_port {
  type = number
}

variable task_definition_arn {
  type = string
}
