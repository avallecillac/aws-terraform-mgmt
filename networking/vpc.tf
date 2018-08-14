resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway_" "vpc_igw" {
  vpc_id = "${aws_vpc.default_vpc.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default_vpc.id}"
}

resource "aws_route" "igw_route" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0./0"
  gateway_id = "${aws_internet_gateway_.vpc_igw.id}"
}

resource "aws_route_table_association" "rt_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route.igw_route.id}"
}

resource "aws_eip" "elastic_ip" {
  vpc = "${aws_vpc.default_vpc.id}"
  depends_on = "${aws_internet_gateway_.vpc_igw}"
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  allocation_id = "${aws_eip.elastic_ip.id}"
}
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.default_vpc}"
}

resource "aws_route" "nat_route" {
  route_table_id = "${aws_route_table.private_route_table}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
}

resource "aws_route_table_association" "rt_nat_association" {
  subnet_id = "${aws_route_table.private_route_table}"
  route_table_id = "${aws_route.nat_route.id}"
}

