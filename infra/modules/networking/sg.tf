resource "aws_security_group" "public" {
    name = "Public"
    description = "Allow SSH traffic, HDFS web UI, YARN web UI, internal traffic, and outgoing"
    vpc_id= "${aws_vpc.default.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
#    ingress {
#        from_port = 50070
#        to_port = 50070
#        protocol = "tcp"
#        cidr_blocks = ["0.0.0.0/0"]
#    }
#    ingress {
#        from_port = 8088
#        to_port = 8088
#        protocol = "tcp"
#        cidr_blocks = ["0.0.0.0/0"]
#    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.subnet_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "private" {
    name = "Private"
    description = "Allow internal traffic and outgoing"
    vpc_id= "${aws_vpc.default.id}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.subnet_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "private" {
    name = "Private"
    description = "Allow internal traffic and outgoing"
    vpc_id= "${aws_vpc.default.id}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.subnet_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}