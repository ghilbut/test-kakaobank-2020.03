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


locals {
  web_domain = "${var.srv_name}.${var.domain_name}"
  api_domain = "${var.srv_name}-api.${var.domain_name}"

  tags = {
    owner   = "terraform"
    purpose = "kakaobank hiring test"
  }
}
