data "terraform_remote_state" "vpc" {
  backend = "s3" 
  config {
    bucket = "vvv-${var.vvv_env}-state" 
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "repository" {
  backend = "s3"
  config {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "repository/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.sh")}" 
  vars {
    mirror_url = "${data.terraform_remote_state.repository.mirror_url}"
  }

}

data "template_cloudinit_config" "cloudinit" {
  gzip = true 
  base64_encode = true
  part {
    filename = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.bootstrap.rendered}"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "security/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_instance" "bastion" {
  user_data = "${data.template_cloudinit_config.cloudinit.rendered}"
  ami = "${data.aws_ami.source.id}"
  subnet_id = "${data.terraform_remote_state.vpc.public_subnet_id}"
  key_name = "${var.key_name}"
  instance_type = "t2.micro"
  tags {
    Name = "bastion"
    Environment = "${var.vvv_env}"
  }
  vpc_security_group_ids = [
    "${data.terraform_remote_state.security.bastion_sg_id}",
    "${data.terraform_remote_state.vpc.internet_updates_sg_id}"
  ]
}

resource "aws_eip_association" "public" {
  instance_id = "${aws_instance.bastion.id}" 
  allocation_id = "${data.terraform_remote_state.vpc.aws_eip_public_id}"
}

data "aws_eip" "bastion" {
  id = "${data.terraform_remote_state.vpc.aws_eip_public_id}"
}

output "bastion_public" {
  value = "${data.aws_eip.bastion.public_ip}"
}

data "aws_ami" "source" { 
  most_recent = true
  filter {
    name = "tag:Component"
    values = ["source-ami"] 
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["291569072141"]
}

data "aws_ami" "ubuntu" { 
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"] 
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

