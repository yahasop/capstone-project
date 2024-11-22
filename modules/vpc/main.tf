data "http" "my-ip" {
  url = "https://ifconfig.me"
}

resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true #This enables DNS hostname to be used within this VPC

  tags = {
    Name = "My-VPC"
  }
}

#A gateway to internet. Every VPC needs one if they want to connect to public internet
resource "aws_internet_gateway" "my-internet-gate" {
  vpc_id = aws_vpc.my-vpc.id
}

#Three subnets, each for an instance
#I set their availabilty zone to manually provision they there
#Also a CIDR block to declare how many IP can be allocated into each one
#An option to provision a public IP for each one
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 2"
  }
}

#A route table that will direct traffic within the VPC
#In this case, will direct traffic from anywhere (0.0.0.0/0) to the VPC
#The internet gateway is attached to allow the traffic
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gate.id
  }
}

#A table association, will add subnets to the route table
#This is the difference between a public and private subnet
#Public subnet is attached to a public facing route table whereas a private not, only internal routing tables
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.my-route-table.id
}

#This security group sets 3 ingress rules and 1 egress
# - Traffic from everywhere is allowed on 80 (HTTP) and 443 (HTTPS) ports
# - Traffic from only Terraform host is allowed on 22 (SSH) port
# - Traffic to everywhere is allowed
resource "aws_security_group" "alb-secgroup" {
  name   = "alb-secgroup"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "Allow external access trough 80 port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow external access trough 443 port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow external access trough 22 port only by MyIP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"]
  }

  ingress {
    description = "Allow external access trough 8080 port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow external access trough 8081 port"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow external access trough 8082 port"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow external access trough 3306 port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}