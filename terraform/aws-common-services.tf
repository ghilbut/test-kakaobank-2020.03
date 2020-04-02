################################################################
##
##  Route 53
##

data aws_route53_zone public {
  name         = var.domain_name
  private_zone = false
}
