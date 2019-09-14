terraform {
  backend "s3" {
    bucket = "vvv-laptop-backup-state"
    key    = "data-generator/terraform.tfstate"
    region = "eu-west-2"
  }
}

