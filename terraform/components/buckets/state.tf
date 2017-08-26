terraform {
  backend "s3" {
    bucket = "vvv-laptop-backup-state"
    key    = "buckets/terraform.tfstate"
    region = "eu-west-2"
  }
}
