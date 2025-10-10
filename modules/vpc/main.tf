#This data block stores information about the local machine's IPv4
#Basically the URL is an API that returns the IPv4 of the machine making the request
data "http" "my-ip" {
  url = "https://ipv4.icanhazip.com"
}

#Creates the VPC where the resources will be allocated
resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true #This enables DNS hostname to be used within this VPC

  tags = {
    Name = "My-VPC"
  }
}

#A gateway to enable traffic into and onto public internet
resource "aws_internet_gateway" "my-internet-gate" {
  vpc_id = aws_vpc.my-vpc.id
}

#Two subnets for this project. Instances managed for the ASG will be allocated in those subnets
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24" #Amount of IP's that can be allocated
  availability_zone       = "us-east-1a"  #Set the availabilty zone
  map_public_ip_on_launch = true          #Instances launched into subnet should be assigned a public IP
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.2.0/24" #Amount of IP's that can be allocated
  availability_zone       = "us-east-1b"  #Set the availabilty zone
  map_public_ip_on_launch = true          #Instances launched into subnet should be assigned a public IP
  tags = {
    Name = "Public Subnet 2"
  }
}

#A gateway to enable traffic into and onto public internet
#Will direct traffic from anywhere (0.0.0.0/0) to the VPC
#The internet gateway is attached to allow the public traffic
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

#This security group sets 5 ingress rules and 1 egress
resource "aws_security_group" "alb-secgroup" {
  name   = "alb-secgroup"
  vpc_id = aws_vpc.my-vpc.id

  #Traffic from anywhere is allowed on 80 (HTTP), 443 (HTTPS) and 8080 ports
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow external access trough ${ingress.value} port"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  #Traffic from only local machine (host) is allowed on 22 (SSH) port
  ingress {
    description = "Allow external access trough 22 port only from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"]
  }

  ingress {
    description = "Allow all traffic within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # Allows all protocols
    cidr_blocks = ["10.0.0.0/16"] #VPC CIDR block
  }

  #Traffic to anywhere is allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}