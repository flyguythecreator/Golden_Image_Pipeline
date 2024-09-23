resource "tls_private_key" "internal_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "auth" {
    key_name = "Default SSH"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_key_pair" "internal_auth" {
    key_name = "Internal Key"
    public_key = "${tls_private_key.internal_key.public_key_openssh}"
}