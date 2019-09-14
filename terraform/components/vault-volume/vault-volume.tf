data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_subnet" "private" {
  id = data.terraform_remote_state.vpc.outputs.private_subnet_id
}

resource "aws_ebs_volume" "vault" {
  type = "gp2"
  tags = {
    Environment = var.vvv_env
    Name        = "vault"
  }
  size              = 1
  availability_zone = data.aws_subnet.private.availability_zone
}

output "vault_volume_id" {
  value = aws_ebs_volume.vault.id
}

