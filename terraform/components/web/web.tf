data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    region = "eu-west-2"
    key    = "vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    region = "eu-west-2"
    key = "security/terraform.tfstate"
  }
}

data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    region = "eu-west-2"
    key = "repository/terraform.tfstate"
  }
}

data "aws_ami" "source" {
  most_recent = true
  filter {
    name = "tag:Component"
    values = ["source-ami"]
  }
  owners = ["140379362680"]
}

data "template_file" "bootstrap" {
  template = file("${path.module}/templates/bootstrap.sh")
  vars = {
    vvv_env = var.vvv_env
  }
}


data "template_file" "node_exporter_bootstrap" {
  template = file("${path.module}/templates/node_exporter_bootstrap.sh")
  vars     = {}
}

data "template_cloudinit_config" "cloudinit" {
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.node_exporter_bootstrap.rendered
    filename     = "node_exporter_bootstrap.sh"
  }
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap.rendered
    filename     = "bootstrap.sh"
  }
}

resource "aws_security_group" "web" {
  name = "web"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "to_internet" {
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  type                     = "egress"
  security_group_id        = aws_security_group.web.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "to_internet_tls" {
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  type                     = "egress"
  security_group_id        = aws_security_group.web.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "from_internet" {
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  type                     = "ingress"
  security_group_id        = aws_security_group.web.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "from_internet_tls" {
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
  security_group_id        = aws_security_group.web.id
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "to_repository_server" {
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  type                     = "egress"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = data.terraform_remote_state.security.outputs.repository_sg_id
}

resource "aws_instance" "web" {
  user_data     = data.template_cloudinit_config.cloudinit.rendered
  ami           = data.aws_ami.source.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_id
  key_name      = var.key_name
  instance_type = "t3.micro"
  tags = {
    Name        = "web"
    Environment = var.vvv_env
  }
  vpc_security_group_ids = [
    data.terraform_remote_state.security.outputs.need_secrets_sg_id,
    data.terraform_remote_state.vpc.outputs.public_sg_id,
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
    aws_security_group.web.id
  ]
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}

output "web_private_dns" {
  value = aws_instance.web.private_dns
}
