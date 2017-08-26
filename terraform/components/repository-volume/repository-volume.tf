data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_subnet" "private" {
  id = "${data.terraform_remote_state.vpc.private_subnet_id}"
}

resource "aws_ebs_volume" "mirror" {
  type = "sc1"
  tags {
    Environment = "${var.vvv_env}"
    Name = "mirror"
  }
  size = 500
  availability_zone = "${data.aws_subnet.private.availability_zone}" 
}

output "mirror_volume_id" {
  value = "${aws_ebs_volume.mirror.id}"
}

