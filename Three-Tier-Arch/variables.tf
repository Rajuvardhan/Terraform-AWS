variable "aws_region" {
    default = "ap-south-1"  
}

variable "vpc_cidr" {
    default = "10.105.0.0/24"
     
}

variable "public_subnet_cidr" {
    default = "10.105.0.0/26"   
  
}

variable "public_subnet1_cidr" {
    default = "10.105.0.192/26"   
  
}

variable "private_subnet1_cidr" {
    default = "10.105.0.64/26" 
  
}

variable "private_subnet2_cidr" {
    default = "10.105.0.128/26"
  
}

variable "availability_zone" {
    default = "ap-south-1a"

}
  
variable "availability_zone-1b" {
    default = "ap-south-1b"
}

variable "ami-id" {
    default = "ami-0ff91eb5c6fe7cc86"  
}
variable "instance_type" {
    default = "t2.micro"  
}
