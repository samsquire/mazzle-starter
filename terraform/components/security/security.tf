resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "bastion box security group"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  tags {
    Name = "bastion"
    Environment = "${var.vvv_env}"
  }
}


resource "aws_security_group" "vault" {
  name = "vault"
  description = "vault"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  tags {
    Name = "vault"
    Environment = "${var.vvv_env}"
  }
}

resource "aws_security_group_rule" "needs_secrets_to_vault" {
  protocol = "tcp"
  from_port = 8200
  to_port = 8200
  type = "egress"
  security_group_id = "${aws_security_group.needs_secrets.id}"
  source_security_group_id = "${aws_security_group.vault.id}"
}

resource "aws_security_group_rule" "vault_from_needs_secrets" {
  protocol = "tcp"
  from_port = 8200
  to_port = 8200
  type = "ingress"
  source_security_group_id = "${aws_security_group.needs_secrets.id}"
  security_group_id = "${aws_security_group.vault.id}"
}

resource "aws_security_group" "needs_secrets" {
  name = "needs_secrets"
  description = "needs_secrets"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  tags {
    Name = "needs_secrets"
    Environment = "${var.vvv_env}"
  }
}


output "bastion_sg_id" {
  value = "${aws_security_group.bastion.id}"
}

output "need_secrets_sg_id" {
  value = "${aws_security_group.needs_secrets.id}"
}
output "vault_sg_id" {
  value = "${aws_security_group.vault.id}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3" 
  config {
    bucket = "vvv-${var.vvv_env}-state" 
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_security_group_rule" "private_from_bastion_ssh" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  type = "ingress" 
  from_port = 22
  to_port = 22
}

resource "aws_security_group_rule" "infrastructure_from_bastion_ssh" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  type = "ingress" 
  from_port = 22
  to_port = 22
}

resource "aws_security_group_rule" "bastion_from_me_ssh" {
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = ["82.26.172.70/32"]
  from_port = 22
  to_port = 22
  type = "ingress"
}

resource "aws_security_group_rule" "bastion_from_me_work_ssh" {
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = ["86.53.244.42/32"]
  from_port = 22
  to_port = 22
  type = "ingress"
}


resource "aws_security_group_rule" "bastion_to_private_ssh" {
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  from_port = 22
  to_port = 22
  type = "egress"
}

resource "aws_security_group_rule" "bastion_to_infrastructure_ssh" {
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  from_port = 22
  to_port = 22
  type = "egress"
}

resource "aws_security_group_rule" "bastion_to_infrastructure_updates" {
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  from_port = 80
  to_port = 80
  type = "egress"
}

resource "aws_security_group_rule" "private_to_infrastructure_updates" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  from_port = 80
  to_port = 80
  type = "egress"
}

resource "aws_security_group_rule" "infrastructure_from_private_updates" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  from_port = 80
  to_port = 80
  type = "ingress"
}

resource "aws_security_group_rule" "infrastructure_from_bastion_updates" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  from_port = 80
  to_port = 80
  type = "ingress"
}

resource "aws_security_group_rule" "private_to_internet_encrypted" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
  type = "egress"
}

resource "aws_security_group_rule" "private_to_internet_unencrypted" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.private_sg_id}"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
  type = "egress"
}

resource "aws_security_group_rule" "internet_updates_rsync" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.rsync_updates_sg_id}"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 873
  to_port = 873
  type = "egress"
}

resource "aws_security_group_rule" "internet_updates_to_internet_unencrypted" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.internet_updates_sg_id}"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
  type = "egress"
}

resource "aws_security_group_rule" "internet_updates_to_internet_encrypted" {
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.vpc.internet_updates_sg_id}"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
  type = "egress"
}

resource "aws_security_group_rule" "infrastructure_from_prometheus" {
  security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.prometheus_sg_id}"
  type = "ingress"
  protocol = "tcp"
  from_port = 9100
  to_port = 9100
}

resource "aws_security_group_rule" "prometheus_to_infrastructure" {
  source_security_group_id = "${data.terraform_remote_state.vpc.infrastructure_sg_id}"
  security_group_id = "${data.terraform_remote_state.vpc.prometheus_sg_id}"
  type = "egress"
  protocol = "tcp"
  from_port = 9100
  to_port = 9100
}


