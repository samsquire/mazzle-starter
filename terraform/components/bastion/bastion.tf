data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "repository/terraform.tfstate"
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

data "template_file" "bootstrap" {
  template = file("${path.module}/templates/bootstrap.sh")

}

data "template_cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true
  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap.rendered
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

resource "aws_instance" "bastion" {
  user_data     = data.template_cloudinit_config.cloudinit.rendered
  ami           = data.aws_ami.source.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_id
  key_name      = var.key_name
  instance_type = "t3.micro"
  tags = {
    Name        = "bastion"
    Environment = var.vvv_env
  }
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
    data.terraform_remote_state.security.outputs.bastion_sg_id,
    data.terraform_remote_state.vpc.outputs.internet_updates_sg_id,
  ]
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion_private_dns" {
  value = aws_instance.bastion.private_dns
}

resource "aws_eip_association" "public" {
  instance_id   = aws_instance.bastion.id
  allocation_id = data.terraform_remote_state.vpc.outputs.aws_eip_public_id
}

data "aws_eip" "bastion" {
  id = data.terraform_remote_state.vpc.outputs.aws_eip_public_id
}

output "bastion_public" {
  value = data.aws_eip.bastion.public_ip
}

data "aws_ami" "source" {
  most_recent = true
  filter {
    name   = "tag:Component"
    values = ["source-ami"]
  }
  owners = ["140379362680"]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"]
}
