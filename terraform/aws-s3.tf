resource "aws_s3_bucket" "state_bucket" {
  bucket = "vvv-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name = "vvv terraform state bucket"
  }
}
