provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "devops-part-one" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "devops-part-one" {
  vpc_id = "${aws_vpc.devops-part-one.id}"
  cidr_block = "10.0.0.0/24"
}

resource "aws_route_table" "devops-part-one" {
  vpc_id = "${aws_vpc.devops-part-one.id}"
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.devops-part-one.id}"
  }
}

resource "aws_route_table_association" "devops-part-one" {
  subnet_id = "${aws_subnet.devops-part-one.id}"
  route_table_id = "${aws_route_table.devops-part-one.id}"
}

resource "aws_internet_gateway" "devops-part-one" {
  vpc_id = "${aws_vpc.devops-part-one.id}"
}


resource "aws_network_acl" "devops-part-one" {
  vpc_id = "${aws_vpc.devops-part-one.id}"
  subnet_ids = ["${aws_subnet.devops-part-one.id}"]
}

resource "aws_network_acl_rule" "devops-part-one-ingress" {
  network_acl_id = "${aws_network_acl.devops-part-one.id}"
  rule_number = 100
  rule_action= "allow"
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

resource "aws_network_acl_rule" "devops-part-one-egress" {
  network_acl_id = "${aws_network_acl.devops-part-one.id}"
  rule_number = 100
  rule_action= "allow"
  protocol = "tcp"
  egress = true
  cidr_block = "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

resource "aws_security_group" "devops-part-one" {
  name = "devops-part-one"
  tags {
    Name = "devops-part-one"
  }
  description = "devops-part-one"

}
resource "aws_security_group_rule" "devops-part-one" {
  type = "ingress"
  to_port = 22
  from_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.devops-part-one.id}"
}

resource "aws_eip" "devops-part-one" {
  instance = "${aws_instance.devops-part-one.id}"
  vpc = true
}

resource "aws_instance" "devops-part-one" {
  ami = "ami-f3810f84"
  instance_type = "t1.micro"
  depends_on = ["aws_internet_gateway.devops-part-one"]
  tags {
    Name = "devops-part-one"
  }
  vpc_security_group_ids = ["${aws_security_group.devops-part-one.id}"]
  key_name = "main"
}
