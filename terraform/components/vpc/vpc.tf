resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames = true
}
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}" 
  cidr_block = "10.0.0.0/25"

  tags {
    Name = "public"
  }
}
output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}" 
  tags {
    Name = "main internet gateway"
  }
}

resource "aws_eip" "outbound" {
  vpc = "true"
}


resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = "${aws_subnet.public.id}"  
  allocation_id = "${aws_eip.outbound.id}"  
}

resource "aws_eip" "public" {
  vpc = "true" 
}

output "aws_eip_public_id" {
  value = "${aws_eip.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "private routes"
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = "${aws_route_table.private.id}" 
  subnet_id = "${aws_subnet.private.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "public routes"
  }
}

resource "aws_route" "to_internet" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"
  depends_on = ["aws_route_table.public"]
}

resource "aws_route" "to_nat_gateway" {
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  depends_on = ["aws_nat_gateway.nat_gateway"]
}

resource "aws_route_table_association" "to_internet" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.vpc.id}" 
  cidr_block = "10.0.0.128/25"

  tags {
    Name = "private"
  }
}
output "private_subnet_id" {
  value = "${aws_subnet.private.id}"
}

resource "aws_security_group" "private" {
  name = "private"
  description = "private security group"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "private"
    Environment = "${var.vvv_env}"
  }
}

resource "aws_security_group" "infrastructure" {
  name = "infra"
  description = "infrastructure security group"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "infrastructure"
    Environment = "${var.vvv_env}"
  }
}

resource "aws_security_group" "rsync_updates" {
  name = "rsync_updates"
  description = "rsync_updates security group"
  vpc_id = "${aws_vpc.vpc.id}" 
  tags {
    Name = "rsync_updates"
    Environment = "${var.vvv_env}"
  }
}

resource "aws_security_group" "internet_updates" {
  name = "internet_updates"
  description = "internet_updates security group"
  vpc_id = "${aws_vpc.vpc.id}" 
  tags {
    Name = "internet_updates"
    Environment = "${var.vvv_env}"
  }
}


output "private_sg_id" {
  value = "${aws_security_group.private.id}"
}

output "infrastructure_sg_id" {
  value = "${aws_security_group.infrastructure.id}"
}

output "internet_updates_sg_id" {
  value = "${aws_security_group.internet_updates.id}"
}
output "rsync_updates_sg_id" {
  value = "${aws_security_group.rsync_updates.id}"
}
