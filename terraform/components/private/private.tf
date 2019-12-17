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

data "aws_ami" "java_ami" {
  most_recent = true
  filter {
    name   = "tag:Component"
    values = ["ubuntu-java"]
  }
  owners = ["140379362680"]
}

data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "repository/terraform.tfstate"
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

resource "aws_instance" "private" {
  user_data     = data.template_cloudinit_config.cloudinit.rendered
  ami           = data.aws_ami.java_ami.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnet_id
  key_name      = var.key_name
  instance_type = "t2.nano"
  tags = {
    Name        = "private"
    Environment = var.vvv_env
  }
  vpc_security_group_ids = [
    data.terraform_remote_state.security.outputs.need_secrets_sg_id,
    data.terraform_remote_state.vpc.outputs.private_sg_id,
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
  ]
}

output "private_instance_ip_address" {
  value = aws_instance.private.private_ip
}

output "private_instance_private_dns" {
  value = aws_instance.private.private_dns
}
