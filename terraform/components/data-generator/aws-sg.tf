resource "aws_security_group" "data_generator" {
  name        = "${var.vvv_env}-vvv-data-generator"
  description = "data generator sg"

  tags {
    Name = "${var.vvv_env} vvv-data-generator"
  }
}

resource "aws_security_group_rule" "ssh_from_prospect_park" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["62.252.63.162/32"]
  security_group_id = "${aws_security_group.data_generator.id}"
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "65000"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.data_generator.id}"
}
