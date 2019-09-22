resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.0.0/25"

  tags = {
    Name = "public"
  }
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "main internet gateway"
  }
}

resource "aws_eip" "outbound" {
  vpc = "true"
}

data "aws_ami" "nat_instance" {
  most_recent = "true"
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

resource "aws_instance" "nat_instance" {
  ami           = data.aws_ami.nat_instance.id
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.nat_instance.id,
  ]
  tags = {
    Name = "nat_instance"
  }
  source_dest_check = false
}

resource "aws_security_group" "nat_instance" {
  name        = "nat_instance"
  description = "nat_instance"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "nat_instance"
  }
}


resource "aws_eip" "nat_instance" {
  vpc = "true"
}

resource "aws_eip_association" "nat_instance" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_instance.id
}

resource "aws_eip" "public" {
  vpc = "true"
}

output "aws_eip_public_id" {
  value = aws_eip.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private routes"
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public routes"
  }
}

resource "aws_route" "to_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route" "to_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"

  // nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  instance_id = aws_instance.nat_instance.id
  depends_on  = [aws_instance.nat_instance]
}

resource "aws_route_table_association" "to_internet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.128/25"

  tags = {
    Name = "private"
  }
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

resource "aws_security_group" "private" {
  name        = "private"
  description = "private security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "private"
    Environment = var.vvv_env
  }
}

resource "aws_security_group" "infrastructure" {
  name        = "infra"
  description = "infrastructure security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "infrastructure"
    Environment = var.vvv_env
  }
}

resource "aws_security_group" "rsync_updates" {
  name        = "rsync_updates"
  description = "rsync_updates security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "rsync_updates"
    Environment = var.vvv_env
  }
}

resource "aws_security_group" "internet_updates" {
  name        = "internet_updates"
  description = "internet_updates security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "internet_updates"
    Environment = var.vvv_env
  }
}

resource "aws_security_group" "prometheus" {
  name        = "prometheus"
  description = "prometheus security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "prometheus"
    Environment = var.vvv_env
  }
}

resource "aws_security_group" "elasticsearch" {
  name        = "elasticsearch"
  description = "elasticsearch security group"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name        = "elasticsearch"
    Environment = var.vvv_env
  }
}


resource "aws_security_group_rule" "from_private" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = [aws_subnet.private.cidr_block]
}

resource "aws_security_group_rule" "from_private_https" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = [aws_subnet.private.cidr_block]
}

resource "aws_security_group_rule" "from_me" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["${var.me}"]
}

resource "aws_security_group_rule" "from_home" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["82.26.172.70/32"]
}

resource "aws_security_group_rule" "to_internet_80" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "to_internet_443" {
  security_group_id = aws_security_group.nat_instance.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "nat_instance_sg_id" {
  value = aws_security_group.nat_instance.id
}

output "prometheus_sg_id" {
  value = aws_security_group.prometheus.id
}

output "private_sg_id" {
  value = aws_security_group.private.id
}

output "infrastructure_sg_id" {
  value = aws_security_group.infrastructure.id
}

output "internet_updates_sg_id" {
  value = aws_security_group.internet_updates.id
}

output "rsync_updates_sg_id" {
  value = aws_security_group.rsync_updates.id
}

output "elasticsearch_sg_id" {
  value = aws_security_group.elasticsearch.id
}
