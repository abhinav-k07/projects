locals {
  my_name         = "${var.prefix}-${var.env}-vpc"
  my_deployment   = "${var.prefix}-${var.env}"
}

resource "aws_vpc" "flaconi-vpc" {
  enable_dns_hostnames = true
  cidr_block           = "${var.vpc_cidr_block}"

  tags = {
    Name        = "${local.my_name}"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.flaconi-vpc.id}"

  tags = {
    Name        = "${local.my_name}-ig"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_subnet" "public-subnet" {

  vpc_id              = "${aws_vpc.flaconi-vpc.id}"
  cidr_block          = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".1.0/24")}"
  availability_zone   = "${var.availability_zone}"


  tags = {
    Name        = "${local.my_name}-public-subnet"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = "${aws_vpc.flaconi-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet-gateway.id}"
  }

  tags = {
    Name        = "${local.my_name}-public-subnet-route-table"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# Route Table Association
resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-subnet-route-table.id}"
}


resource "aws_security_group" "elb-sg" {
  name        = "${local.my_name}-elb-sg"
  description = "Create ingress rules"
  vpc_id      = "${aws_vpc.flaconi-vpc.id}"
  depends_on  = ["aws_internet_gateway.internet-gateway"]


  tags = {
    Name        = "${local.my_name}-public-subnet-sg"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_security_group_rule" "elb-ingress" {

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.app_port}"
  to_port                  = "${var.app_port}"
  security_group_id        = "${aws_security_group.elb-sg.id}"
  source_security_group_id = "${aws_security_group.private-subnet-sg.id}"

}


resource "aws_security_group_rule" "elb-rule" {

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.app_port}"
  to_port                  = "${var.app_port}"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = "${aws_security_group.elb-sg.id}"

}


resource "aws_security_group_rule" "elb-egress" {

  type               = "egress"
  protocol           = "-1"
  from_port          = 0
  to_port            = 0
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = "${aws_security_group.elb-sg.id}"

}


# NAT Gateway Resources

resource "aws_eip" "nat-gw-eip" {
  vpc = true

  tags = {
    Name        = "${local.my_name}-nat-gw-eip"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat-gw-eip.id}"
  subnet_id     = "${aws_subnet.public-subnet.id}"
  depends_on    = ["aws_internet_gateway.internet-gateway"]

  tags = {
    Name        = "${local.my_name}-nat-gw"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}



# This is the Private Subnet hosting EC2 Instances in Auto Scaling Groups.

resource "aws_subnet" "private-subnet" {
  vpc_id            = "${aws_vpc.flaconi-vpc.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".3.0/24")}"

  tags = {
    Name        = "${local.my_name}-private-subnet"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_security_group" "private-subnet-sg" {
  name        = "${local.my_name}-private-subnet-sg"
  description = "Allow inbound access from the ELB"
  vpc_id      = "${aws_vpc.flaconi-vpc.id}"
  depends_on  = ["aws_internet_gateway.internet-gateway"]


  tags = {
    Name        = "${local.my_name}-private-subnet-sg"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_security_group_rule" "private-ingress" {

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.app_port}"
  to_port                  = "${var.app_port}"
  security_group_id        = "${aws_security_group.private-subnet-sg.id}"
  source_security_group_id = "${aws_security_group.elb-sg.id}"

}


resource "aws_security_group_rule" "private-egress" {

  type                = "egress"
  protocol            = "-1"
  from_port           = 0
  to_port             = 0
  cidr_blocks         = ["0.0.0.0/0"]
  security_group_id   = "${aws_security_group.private-subnet-sg.id}"

}



# Private Subnet route table configurations

resource "aws_route_table" "private-subnet-route-table" {
  vpc_id = "${aws_vpc.flaconi-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }

  tags = {
    Name        = "${local.my_name}-private-subnet-route-table"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# From our Private Subnet hosting EC2 Auto Scaling Groups to NAT.

resource "aws_route_table_association" "private-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.private-subnet-route-table.id}"
}