data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "dns/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "security/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "volume" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vault-volume/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_ami" "vault" {
  most_recent = true

  filter {
    name   = "tag:Component"
    values = ["vault-ami"]
  }
  owners = ["140379362680"]
}

resource "aws_route53_record" "vault" {
  zone_id = data.terraform_remote_state.dns.outputs.subenvironment_zone_id
  name    = "vault"
  type    = "A"
  ttl     = "30"
  records = [
    aws_instance.vault.private_ip,
  ]
}

resource "aws_iam_role" "vault" {
  name               = "vault"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "vault" {
  name = "vault"
  role = aws_iam_role.vault.name
}

data "template_file" "bootstrap" {
  template = file("${path.module}/templates/01-bootstrap.sh")
  vars = {
    vvv_env = var.vvv_env
    domain = var.domain
  }
}

module "volume" {
  source      = "../../module-templates/volume-mounting/"
  role        = aws_iam_role.vault.name
  device_name = "/dev/xvdb"
  mount_point = "/data/vault"
}

data "template_cloudinit_config" "vault" {
  gzip          = true
  base64_encode = true
  part {
    filename     = "00-volume_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = module.volume.rendered_volume_bootstrap
  }
  part {
    content_type = "text/cloud-config"
    content      = module.volume.rendered_cloudconfig
  }
  part {
    filename     = "01-bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap.rendered
  }
}

resource "aws_instance" "vault" {
  depends_on = [
    aws_iam_instance_profile.vault,
    aws_iam_role.vault,
    module.volume,
  ]
  iam_instance_profile = aws_iam_instance_profile.vault.name
  ami                  = data.aws_ami.vault.id
  user_data            = data.template_cloudinit_config.vault.rendered
  subnet_id            = data.terraform_remote_state.vpc.outputs.private_subnet_id
  key_name             = var.key_name
  instance_type        = "t2.nano"
  tags = {
    Name        = "vault"
    Environment = var.vvv_env
    Volume      = data.terraform_remote_state.volume.outputs.vault_volume_id
  }
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
    data.terraform_remote_state.vpc.outputs.private_sg_id,
    data.terraform_remote_state.security.outputs.vault_sg_id,
  ]
}

output "vault_private_ip" {
  value = aws_instance.vault.private_ip
}
