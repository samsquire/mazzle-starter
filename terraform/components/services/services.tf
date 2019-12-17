data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "dns/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "bastion/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "prometheus" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "prometheus/terraform.tfstate"
    region = "eu-west-2"
  }
}
/*
data "terraform_remote_state" "elasticsearch" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "elasticsearch/terraform.tfstate"
    region = "eu-west-2"
  }
} */

data "terraform_remote_state" "vault" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "vault/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "private" {
  backend = "s3"
  config = {
    bucket = "vvv-${var.vvv_env}-state"
    key    = "private/terraform.tfstate"
    region = "eu-west-2"
  }
}

/*
concat(
  formatlist(
    "1 1 9100 %s",
    data.terraform_remote_state.elasticsearch.outputs.elasticsearch_private_ip,
  ),
  */

resource "aws_route53_record" "nodes" {
  type    = "SRV"
  name    = "nodes"
  zone_id = data.terraform_remote_state.dns.outputs.subenvironment_zone_id
  ttl     = "30"
  records = [
      "1 1 9100 ${data.terraform_remote_state.bastion.outputs.bastion_private_ip}",
      "1 1 9100 ${data.terraform_remote_state.vault.outputs.vault_private_ip}",
      "1 1 9100 ${data.terraform_remote_state.prometheus.outputs.prometheus_private_ip}",
    ]
}


output "services_fqdn" {
  value = aws_route53_record.nodes.fqdn
}

output "cluster" {
  value = "${data.terraform_remote_state.bastion.outputs.bastion_private_dns} ${data.terraform_remote_state.vault.outputs.vault_private_dns} ${data.terraform_remote_state.prometheus.outputs.prometheus_private_dns}"
}
