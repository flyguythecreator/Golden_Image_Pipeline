resource "aws_vpc" "primary" {
    cidr_block = "${var.vpc_cidr_primary}"
    enable_dns_hostnames = true
    tags {
        Name = "Hadoop Cluster VPC"
    }
}

resource "aws_vpc" "secondary" {
  cidr_block           = "10.7.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "default" {
    vpc_id = "${aws_vpc.primary.id}"
    cidr_block = "${var.subnet_cidr}"
    tags {
        Name = "Default Subnet"
    }
}

#resource "aws_subnet" "private" {
#    vpc_id = "${aws_vpc.default.id}"
#    cidr_block = "${var.private_cidr}"
#    tags {
#        Name = "Private Subnet"
#    }
#}

resource "aws_internet_gateway" "example" {
    vpc_id = "${aws_vpc.primary.id}"
    tags {
        Name = "Internet Gateway"
    }
}

resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.example.id
  vpc_id              = aws_vpc.example.id
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.default.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.example]
}



resource "aws_route_table" "internet_access" {
    vpc_id = "${aws_vpc.primary.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.example.id}"
    }
}

resource "aws_route_table_association" "internet_access" {
    subnet_id = "${aws_subnet.default.id}"
    route_table_id = "${aws_route_table.internet_access.id}"
}