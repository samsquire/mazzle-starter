data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "vvv-${var.vvv_env}-state" 
    key = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_ami" "source_ami" {
  most_recent = "true" 
  filter {
    name = "tag:Component" 
    values = ["ubuntu-java"]
  }

}

data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.sh")}"

  vars {
    vvv_env = "${var.vvv_env}"
  }
}

data "template_file" "node_exporter_bootstrap" {
  template = "${file("${path.module}/../../templates/node_exporter_bootstrap.sh")}"
  vars {}
}

data "template_cloudinit_config" "bootstrap" {
  gzip = "true"
  base64_encode = "true"

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.node_exporter_bootstrap.rendered}"
    filename = "node_exporter_bootstrap.sh"
  }
  part {
    content_type = "text/x-shellscript" 
    content = "${data.template_file.bootstrap.rendered}"
  }
}

resource "aws_instance" "elasticsearch" {
  instance_type = "t2.nano" 
  count = "1" 
  ami = "${data.aws_ami.source_ami.id}"
  key_name = "${var.key_name}"
  subnet_id = "${data.terraform_remote_state.vpc.private_subnet_id}"
  user_data = "${data.template_cloudinit_config.bootstrap.rendered}" 
  vpc_security_group_ids = [
    "${data.terraform_remote_state.vpc.infrastructure_sg_id}",
    "${data.terraform_remote_state.vpc.elasticsearch_sg_id}"
  ]
  tags {
    Name = "elasticsearch${count.index}"
  }
}

output "elasticsearch_private_ip" {
  value = ["${aws_instance.elasticsearch.*.private_ip}"]
}

resource "aws_security_group_rule" "to_nat_instance_http" {
  security_group_id = "${data.terraform_remote_state.vpc.elasticsearch_sg_id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.nat_instance_sg_id}"
  type = "egress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
}

resource "aws_security_group_rule" "to_nat_instance_https" {
  security_group_id = "${data.terraform_remote_state.vpc.elasticsearch_sg_id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.nat_instance_sg_id}"
  type = "egress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
}

