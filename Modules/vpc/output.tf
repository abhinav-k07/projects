# EC2 Auto Scaling network configuration needs these.
output "vpc_id" {
  value = "${aws_vpc.flaconi-vpc.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private-subnet.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public-subnet.id}"
}

output "internet_gateway_id" {
  value = ["${aws_internet_gateway.internet-gateway.id}"]
}


output "private_subnet_availability_zones" {
  value = ["${aws_subnet.private-subnet.availability_zone}"]
}

output "public-subnet-sg_id" {
  value = "${aws_security_group.elb-sg.id}"
}

output "private_subnet_sg_id" {
  value = "${aws_security_group.private-subnet-sg.id}"
}

output "nat_eip" {
  value = "${aws_nat_gateway.nat-gw.public_ip}"
}
