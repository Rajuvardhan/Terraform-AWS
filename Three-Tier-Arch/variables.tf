variable "aws_region" {
    description = "region for aws resources"  
}

variable "vpc_cidr" {
    description = "cidr range for vpc"
     
}

variable "public_subnet_cidr" {
    description = "public subnet 1"   
  
}

variable "public_subnet1_cidr" {
    description = "public subnet 2"   
  
}

variable "private_subnet1_cidr" {
    description = "private subnet 1" 
  
}

variable "private_subnet2_cidr" {
    description = "private subnet 2"
  
}

variable "availability_zone" {
    description = "avaialbility zone 1"

}
  
variable "availability_zone-1b" {
    description = "avaialbility zone 2"
}

variable "ami-id" {
    description = "ami id for ec2"  
}
variable "instance_type" {
    description = "instance_type for ec2"  
}
