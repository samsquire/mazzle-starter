resource "aws_s3_bucket" "state_bucket" {
  bucket = "vvv-${var.vvv_env}-state"
  acl    = "private"
  region = "eu-west-2"

  versioning {
    enabled = true
  }

  tags {
    Name = "vvv ${var.vvv_env} terraform state bucket"
  }
}

resource "aws_s3_bucket" "outputs_bucket" {
  bucket = "vvv-${var.vvv_env}-outputs"
  acl    = "private"
  region = "eu-west-2"

  versioning {
    enabled = true
  }

  tags {
    Name = "vvv ${var.vvv_env} output bucket"
  }
}

resource "aws_s3_bucket" "backup_bucket" {
  bucket = "vvv-${var.vvv_env}-content"
  acl    = "private"
  region = "eu-west-2"

  tags {
    Name = "vvv ${var.vvv_env} laptop backups"
  }
}
