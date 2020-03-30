terraform {
  required_version = "~> 0.12.6"

  backend s3 {
    bucket  = "seoul-public-parking-lot-terraform"
    key     = "terraform.tfstate"

    profile = "ghilbut"
    region  = "ap-northeast-2"
    encrypt = true
  }
}
