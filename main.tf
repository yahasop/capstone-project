provider "aws" {
  region = var.aws_region
}

#This data block stores information about the local machine's IPv4
#Basically the URL is an API that returns the IPv4 of the machine making the request
data "http" "my-ip" {
  url = "https://ipv4.icanhazip.com"
}

#The next three blocks are used to provision a key pair and create the file in the local system
#This creates the aws key pair resource using the tls block 
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

#The resource provides a PEM formatted private key using RSA 
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#The resource creates a local file where the terraform configuration files exist and the contents are the private key
#It uses a local-exec provisioner to change the permissions of the key
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
  provisioner "local-exec" {
    command = "chmod 400 ./tf-key-pair"
  }
}

#Creates the VPC where the resources will be allocated
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "Jenkins-Agent-VPC"
  }
}

#A gateway to enable traffic into and onto public internet
#Will direct traffic from anywhere (0.0.0.0/0) to the VPC
#The internet gateway is attached to allow the public traffic
resource "aws_internet_gateway" "my-vpc-ig" {
  vpc_id = aws_vpc.my-vpc.id
}

#Provision a subnet within the VPC
resource "aws_subnet" "my-public_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.vpc_public_subnet_cidr_block
  availability_zone       = "us-east-1a" #Availability zone for the Subnet
  map_public_ip_on_launch = true           #Instances launched into subnet should be assigned a public IP

  tags = {
    Name = "Jenkins-Agent-Subnet"
  }
}

#A route table that will direct traffic within the VPC
#In this case, will direct traffic from anywhere (0.0.0.0/0) to the VPC
#The internet gateway is attached to allow the public traffic
resource "aws_route_table" "my-vpc-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = var.anywhere_cidr_block
    gateway_id = aws_internet_gateway.my-vpc-ig.id
  }
}

#A table association, will add subnets to the route table
#This is the difference between a public and private subnet
#Public subnet is attached to a public facing route table whereas a private not, only internal routing tables
resource "aws_route_table_association" "my-public-subnet-rta" {
  subnet_id      = aws_subnet.my-public_subnet.id
  route_table_id = aws_route_table.my-vpc-rt.id
}

#This security group sets 3 ingress rules and 1 egress
resource "aws_security_group" "my-jenkins-agent-sg" {
  name   = "my-jenkins-agent-sg"
  vpc_id = aws_vpc.my-vpc.id

  #Requests from anywhere are allowed on 80 (HTTP) and 443 (HTTPS) ports
  ingress {
    description = "Allow external access trough 80 port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.anywhere_cidr_block]
  }

  ingress {
    description = "Allow external access trough 443 port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.anywhere_cidr_block]
  }

  #Requests from only local machine are allowed on 22 (SSH) port
  ingress {
    description = "Allow external access trough 22 port only from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"] #This sets local machine IP using the data block and formatting
  }

  #Traffic to anywhere is allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anywhere_cidr_block]
  }
}

#Provisions the jenkins-agent instance to use it as agent to run the jobs
resource "aws_instance" "jenkins-agent" {
  ami                    = "ami-005fc0f236362e99f" #Ubuntu22 AMI
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.my-public_subnet.id #Subnet the instance will belong to
  vpc_security_group_ids = [aws_security_group.my-jenkins-agent-sg.id]
  key_name               = "tf-key-pair" #Pem key associated to the instance. Neccesary to log into
  depends_on             = [local_file.tf-key]
  user_data              = filebase64("user_data.sh") #Script that runs after the instance provisions

  tags = {
    Name = "Jenkins-Agent"
  }
}