data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    region = "eu-west-2"
    key    = "vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    region = "eu-west-2"
    key    = "dns/terraform.tfstate"
  }
}

data "aws_ami" "source" {
  most_recent = "true"
  filter {
    name   = "tag:Component"
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

data "template_cloudinit_config" "bootstrap" {
  gzip          = true
  base64_encode = true

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

resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.source.id
  instance_type = "t2.nano"
  subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnet_id
  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.prometheus_sg_id,
    data.terraform_remote_state.vpc.outputs.infrastructure_sg_id,
  ]
  user_data = data.template_cloudinit_config.bootstrap.rendered
  tags = {
    Name        = "prometheus"
    Environment = var.vvv_env
  }
  key_name = var.key_name
}

output "prometheus_private_ip" {
  value = aws_instance.prometheus.private_ip
}
output "prometheus_private_dns" {
  value = aws_instance.prometheus.private_dns
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.terraform_remote_state.dns.outputs.subenvironment_zone_id
  name    = "prometheus"
  type    = "A"
  ttl     = "30"
  records = [
    aws_instance.prometheus.private_ip,
  ]
}

resource "aws_security_group_rule" "to_nat_instance_http" {
  security_group_id        = data.terraform_remote_state.vpc.outputs.prometheus_sg_id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.nat_instance_sg_id
  protocol                 = "tcp"
  from_port                = "80"
  to_port                  = "80"
  type                     = "egress"
}

resource "aws_security_group_rule" "to_nat_instance_https" {
  security_group_id        = data.terraform_remote_state.vpc.outputs.prometheus_sg_id
  source_security_group_id = data.terraform_remote_state.vpc.outputs.nat_instance_sg_id
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  type                     = "egress"
}
