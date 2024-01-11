resource "aws_security_group" "checkday_worker_node_security_group" {
    name = "checkday_worker_node_security_group"
    description = "Allows SSH Inbound Traffic"
    vpc_id = aws_vpc.checkday_vpc.id

    ingress {
        description = "SSH access to Subnet"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}