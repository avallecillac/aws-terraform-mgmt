provider "aws" {
    region = "${var.region}"
    profile = "${var.profile}"
}

resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = "${aws_vpc.default_vpc.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default_vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.vpc_igw.id}"
  }
}

resource "aws_route_table_association" "rt_public_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_eip" "elastic_ip" {
  vpc = true

  depends_on = ["aws_internet_gateway.vpc_igw"]
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  allocation_id = "${aws_eip.elastic_ip.id}"
}
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.default_vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
}

resource "aws_route_table_association" "rt_nat_association" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
