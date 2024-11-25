terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

#Uses the vpc module
module "vpc" {
  source = "./modules/vpc"
}

#The alb module need to use resources from the vpc module. 
#As both are child of the root, and same level the resources from vpc are declared in this block
#Variables for the resources needs to be declared within the alb module
module "alb" {
  source           = "./modules/alb"
  vpc-id           = module.vpc.vpc
  subnet1-id       = module.vpc.subnet-1
  subnet2-id       = module.vpc.subnet-2
  secgroup-id      = module.vpc.alb-secgroup
  internet-gateway = module.vpc.internet-gateway
}

#Data block to fetch the AMI from available AMI's
#A dependency argument is declared as the AMI needs to be created first
data "aws_ami" "my-ami" {
  owners      = ["self"]
  most_recent = true
  depends_on  = [aws_ami_from_instance.temporaryvm-ami]

  filter {
    name   = "name"
    values = ["temporaryvm_ami-${formatdate("YYYY-MM-DD", timestamp())}"]
  }
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "app-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "app-key-pair"
  provisioner "local-exec" {
    command = "chmod 400 ./app-key-pair"
  }
}

#Temporary VM to create an AMI later from it
resource "aws_instance" "temporary-vm" {
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.subnet-1
  vpc_security_group_ids      = [module.vpc.alb-secgroup]
  associate_public_ip_address = true
  ami                         = "ami-005fc0f236362e99f" #Predefined AMI

  tags = {
    Name = "TemporaryVM"
  }
}

#This block creates the AMI
#A custom name for the AMI is provided using built-in functions
#Disadvantage of this is that every apply the instance will be destroyed and created, as the timestamp changes
#Same happens with the data block as it has the same timestamp
resource "aws_ami_from_instance" "temporaryvm-ami" {
  name                    = "temporaryvm_ami-${formatdate("YYYY-MM-DD", timestamp())}"
  source_instance_id      = aws_instance.temporary-vm.id
  snapshot_without_reboot = true
  depends_on              = [aws_instance.temporary-vm]
}

#The AutoScaling group needs a Launch Template. This creates that
#It uses the recently created AMI (with a dependency on it) and a Shell script that will be provided
resource "aws_launch_template" "my-launch-template" {
  instance_type          = "t3.medium"
  name                   = "my-launch-template"
  image_id               = data.aws_ami.my-ami.id #The result of the data block is used here to fetch the created image
  depends_on             = [aws_ami_from_instance.temporaryvm-ami]
  vpc_security_group_ids = [module.vpc.alb-secgroup]
  key_name = "tf-key-pair"
  user_data              = filebase64("user_data.sh") #Script provided externally. Needs to be translated to 64 bitcode
}

#The resource block that will create the ASG
#The desired capacity will mantain 3 instances at the same time. Max and min are the min and max expected capacity of the scale group
#Uses the launch template and sets dependencies as the ALB needs to be created first
#Also it uses the target group ARN to add the created instances to it. It will add automatically the instances when they are provisioned
resource "aws_autoscaling_group" "my-asg" {
  name                = "my-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [module.vpc.subnet-1, module.vpc.subnet-2]

  launch_template {
    id      = aws_launch_template.my-launch-template.id
    version = "$Latest"
  }

  target_group_arns = [module.alb.alb-tg-arn]
  depends_on        = [module.alb.aws_lb]
}

data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.my-asg.name
  }
}