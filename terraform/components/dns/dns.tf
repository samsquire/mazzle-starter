resource "aws_route53_zone" "zone" {
  name = "devops-pipeline.com"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}

resource "aws_route53_zone" "subenvironment" {
  vpc {
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  }
  name   = "${var.vvv_env}.devops-pipeline.com"
  tags = {
    Environment = var.vvv_env
  }
}

output "subenvironment_zone_id" {
  value = aws_route53_zone.subenvironment.zone_id
}
