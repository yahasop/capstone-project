provider "aws" {
  region = var.aws_region
}

data "http" "my-ip" {
  url = "https://ifconfig.me"
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
  provisioner "local-exec" {
    command = "chmod 400 ./tf-key-pair"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "my-vpc-ig" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_subnet" "my-public_subnet" {
  cidr_block              = var.vpc_public_subnet_cidr_block
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_route_table" "my-vpc-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-vpc-ig.id
  }
}

resource "aws_route_table_association" "my-public-subnet-rta" {
  subnet_id      = aws_subnet.my-public_subnet.id
  route_table_id = aws_route_table.my-vpc-rt.id
}

resource "aws_security_group" "my-sg" {
  name   = "my-jenkins-agent-sg"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins-agent" {
  ami                    = "ami-005fc0f236362e99f"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.my-public_subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name               = "tf-key-pair"
  depends_on             = [local_file.tf-key]
  user_data              = filebase64("user_data.sh")
  
  tags = {
    Name = "Jenkins-Agent"
  }
}