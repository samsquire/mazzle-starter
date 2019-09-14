terraform {
  backend "s3" {
    bucket = "vvv-home-state"
    key    = "buckets/terraform.tfstate"
    region = "eu-west-2"
  }
}
