output mysql_host {
  value = aws_db_instance.mysql.address
  description = "MySQL address"
  sensitive   = true
}

output mysql_port {
  value = aws_db_instance.mysql.port
  description = "MySQL port"
  sensitive   = true
}

output mysql_database {
  value = random_string.mysql_database.result
  description = "MySQL database name"
  sensitive   = true
}

output mysql_username {
  value = random_string.mysql_username.result
  description = "MySQL admin username"
  sensitive   = true
}

output mysql_password {
  value = random_password.mysql_password.result
  description = "MySQL admin password"
  sensitive   = true
}
