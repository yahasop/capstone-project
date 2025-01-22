variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_cidr_block" {
  type        = string
  description = "CIDR Block for Subnet 1 in VPC"
  default     = "10.0.0.0/24"
}

variable "anywhere_cidr_block" {
  type        = string
  description = "CIDR block to allow access from anywhere"
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type        = string
  description = "Type for EC2 Instnace"
  default     = "t3.medium"
}