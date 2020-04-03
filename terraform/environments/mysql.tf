################################################################
##
##  MySQL 5.7
##

##--------------------------------------------------------------
##  Security Group

resource aws_security_group mysql {
  name = "${var.srv_name}-mysql"
  description = "Allow MySQL inbound traffic"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    map(
      "Name",  "sg-${var.srv_name}-mysql",
    ),
    local.tags, 
  )
}

##--------------------------------------------------------------
##  Parameter Group

resource aws_db_parameter_group mysql {
  name   = "${var.srv_name}-mysql"
  family = "mysql5.7"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = merge(
    map(
      "Name",  "pg-${var.srv_name}-mysql",
    ),
    local.tags, 
  )
}

##--------------------------------------------------------------
##  MySQL

resource random_string mysql_database {
  length  = 8
  upper   = false
  number  = false
  special = false
}

resource random_string mysql_username {
  length  = 8
  upper   = false
  number  = false
  special = false
}

resource random_password mysql_password {
  length = 12
  special = true
  override_special = "!@#$%^&*()"
}

resource aws_db_instance mysql {
  allocated_storage     = 20
  availability_zone     = "ap-northeast-2a"
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t3.micro"
  name                  = random_string.mysql_database.result
  username              = random_string.mysql_username.result
  password              = random_password.mysql_password.result
  parameter_group_name  = aws_db_parameter_group.mysql.id

  identifier = "rds-${var.srv_name}-mysql"

  skip_final_snapshot = true
  publicly_accessible = true

  vpc_security_group_ids = [
    aws_security_group.mysql.id,
  ]

  tags = merge(
    map(
      "Name", "rds-${var.srv_name}-mysql",
    ),
    local.tags, 
  )
}



################################################################
##
##  AWS Secret Manager
##

##--------------------------------------------------------------
##  host

resource aws_secretsmanager_secret mysql_host {
  name = "${var.srv_name}-mysql-host"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_host {
  secret_id     = aws_secretsmanager_secret.mysql_host.id
  secret_string = aws_db_instance.mysql.address
}

##--------------------------------------------------------------
##  port

resource aws_secretsmanager_secret mysql_port {
  name = "${var.srv_name}-mysql-port"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_port {
  secret_id     = aws_secretsmanager_secret.mysql_port.id
  secret_string = aws_db_instance.mysql.port
}

##--------------------------------------------------------------
##  database

resource aws_secretsmanager_secret mysql_database {
  name = "${var.srv_name}-mysql-database"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_databse {
  secret_id     = aws_secretsmanager_secret.mysql_database.id
  secret_string = random_string.mysql_database.result
}

##--------------------------------------------------------------
##  username

resource aws_secretsmanager_secret mysql_username {
  name = "${var.srv_name}-mysql-username"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_username {
  secret_id     = aws_secretsmanager_secret.mysql_username.id
  secret_string = random_string.mysql_username.result
}

##--------------------------------------------------------------
##  password

resource aws_secretsmanager_secret mysql_password {
  name = "${var.srv_name}-mysql-password"
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version mysql_password {
  secret_id     = aws_secretsmanager_secret.mysql_password.id
  secret_string = random_password.mysql_password.result
}
