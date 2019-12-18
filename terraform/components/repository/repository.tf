data "aws_ami" "source" {
  most_recent = true
  filter {
    name   = "tag:Component"
    values = ["source-ami"]
  }
  owners = ["140379362680"]
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
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

data "terraform_remote_state" "repository_volume" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "repository-volume/terraform.tfstate"
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

resource "aws_route53_record" "repository" {
  zone_id = data.terraform_remote_state.dns.outputs.subenvironment_zone_id
  name    = "mirror"
  type    = "A"
  ttl     = "30"
  records = [
    aws_instance.repository.private_ip,
  ]
}

module "volume" {
  source      = "../../module-templates/volume-mounting"
  role        = aws_iam_role.repository.name
  device_name = "/dev/xvdb"
  mount_point = "/data/mirror"
}

data "template_file" "bootstrap" {
  template = file("${path.module}/templates/bootstrap.sh")

  vars = {
    device_name = module.volume.device_name
    mirror_url = "mirror.${var.vvv_env}.${var.domain}"
  }
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "volume_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = module.volume.rendered_volume_bootstrap
  }
  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap.rendered
  }

  part {
    content_type = "text/cloud-config"
    content      = module.volume.rendered_cloudconfig
  }
}

resource "aws_iam_role" "repository" {
  name               = "repository"
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

resource "aws_iam_instance_profile" "repository" {
  name = "repository"
  role = aws_iam_role.repository.name
}

resource "aws_instance" "repository" {
  iam_instance_profile = aws_iam_instance_profile.repository.name
  ami                  = data.aws_ami.source.id
  subnet_id            = data.terraform_remote_state.vpc.outputs.private_subnet_id
  key_name             = var.key_name
  user_data            = data.template_cloudinit_config.cloudinit.rendered
  instance_type        = "t2.micro"
  tags = {
    Name        = "repository"
    Environment = var.vvv_env
    Volume      = data.terraform_remote_state.repository_volume.outputs.mirror_volume_id
  }
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
    data.terraform_remote_state.vpc.outputs.internet_updates_sg_id,
    data.terraform_remote_state.vpc.outputs.rsync_updates_sg_id,
    data.terraform_remote_state.security.outputs.need_secrets_sg_id,
  ]
}

output "repository_private_ip" {
  value = aws_instance.repository.private_ip
}

output "mirror_url" {
  value = "mirror.${var.vvv_env}.${var.domain}"
}
