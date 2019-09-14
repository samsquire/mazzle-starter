terraform {
  backend "s3" {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "users/terraform.tfstate"
    region = "eu-west-2"
  }
}
