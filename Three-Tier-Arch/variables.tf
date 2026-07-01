variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet 1 CIDR"
  type        = string
}

variable "public_subnet1_cidr" {
  description = "Public Subnet 2 CIDR"
  type        = string
}

variable "private_subnet1_cidr" {
  description = "Private Subnet 1 CIDR"
  type        = string
}

variable "private_subnet2_cidr" {
  description = "Private Subnet 2 CIDR"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone 1"
  type        = string
}

variable "availability_zone_1b" {
  description = "Availability Zone 2"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}
