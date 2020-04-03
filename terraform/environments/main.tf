terraform {
  required_version = "~> 0.12.6"

  backend s3 {
    bucket  = "seoul-public-parking-lot-service-terraform-state"
    key     = "terraform.tfstate"

    profile = "spps"
    region  = "ap-northeast-2"
    encrypt = true
  }
}


provider aws {
  region  = var.aws_region
  profile = var.aws_profile
}

provider aws {
  alias   = "acm_certificate"
  region  = "us-east-1"
  profile = var.aws_profile
}


locals {
  az_suffixes = ["a", "b"]

  private_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]

  web_domain = "${var.srv_name}.${var.domain_name}"
  api_domain = "${var.srv_name}-api.${var.domain_name}"

  django_container_name = "django"
  django_cpu            = "256"
  django_memory         = "512"
  django_port           = 8000

  alb_django_priority = 100

  tags = {
    owner   = "terraform"
    service = var.srv_name
    purpose = "kakaobank hiring test"
  }
}
