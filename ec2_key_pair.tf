resource "tls_private_key" "checkday_tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "checkday_generated_key_pair" {
  key_name   = "checkday_generated_key_pair"
  public_key = tls_private_key.checkday_tls.public_key_openssh

  tags = {
    Name = "checkday_generated_key_pair"
  }
}