terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "Prod-vp" {

  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "terraform-vpc"

  }

}
#create public subnets
resource "aws_subnet" "public" {
    for_each = {
        public-1 = {
            cidr_block = var.public_subnet_cidr
            availability_zone = var.availability_zone
            map_public_ip_on_launch = true
        }
        public-2 = {
            cidr_block = var.public_subnet1_cidr
            availability_zone = var.availability_zone-1b
            map_public_ip_on_launch = true
        }
    }
    vpc_id = aws_vpc.Prod-vp.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone

    tags = {
        Name= each.key
    }
  
}

#create private subnets
resource "aws_subnet" "private" {
    for_each = {
        private-1 = {
            cidr_block = var.private_subnet1_cidr
            availability_zone = var.availability_zone
            map_public_ip_on_launch = false
        }
        private-2 = {
            cidr_block = var.private_subnet2_cidr
            availability_zone = var.availability_zone-1b
            map_public_ip_on_launch = false
        }
    }
    vpc_id = aws_vpc.Prod-vp.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone

    tags = {
        Name= each.key
    }  
}


# create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.Prod-vp.id

    tags = {
        Name = "prod-internet-gateway"
    }
}

# create route table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.Prod-vp.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "prod-public-route-table"
    }
}

# create route table
resource "aws_route_table" "public_route_table-2" {
    vpc_id = aws_vpc.Prod-vp.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "prod-public-route-table-2"
    }
}
  
# associate public route table with subnet
resource "aws_route_table_association" "pub-subnet-1-route-table-association" {
    subnet_id = aws_subnet.public["public-1"].id
    route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "pub-subnet-2-route-table-association" {
    subnet_id = aws_subnet.public["public-2"].id
    route_table_id = aws_route_table.public_route_table-2.id
}



# Assign Elastic Ip for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.igw]
    tags = {
        Name = "nat-gateway-eip"
    }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_gateway_eip.id
    subnet_id = aws_subnet.public["public-1"].id
    depends_on = [aws_internet_gateway.igw]

    tags = {
        Name = "prod-nat-gateway"
    }
}

# create private route table

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.Prod-vp.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags= {
        Name = "prod-private-route-table"
    }

}

# associate private route table with private subnet-1
resource "aws_route_table_association" "pri-subnet-route-table-association" {
    subnet_id = aws_subnet.private["private-1"].id
    route_table_id = aws_route_table.private_route_table.id
}

# associate private route table with private subnet-2
resource "aws_route_table_association" "pri-subnet-2-route-table-association" {
    subnet_id = aws_subnet.private["private-2"].id
    route_table_id = aws_route_table.private_route_table.id
}

# create security group for bastion host
resource "aws_security_group" "bastion-sg" {
    name = "bastion-sg"
    description = "security group for bastion host"
    vpc_id = aws_vpc.Prod-vp.id

   
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "bastion-sg"
    }
}

# create app server security group
resource "aws_security_group" "app-sg" {
    name = "app-server-sg"
    description = "security group for app servers"
    vpc_id = aws_vpc.Prod-vp.id

    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]    
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id] 
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion-sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create AlB security group
resource "aws_security_group" "alb-sg" {
    name = "alb-sg"
    description = "security group for application load balancer"
    vpc_id = aws_vpc.Prod-vp.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }   
  
}


# launch bastion host
resource "aws_instance" "Bastion-host" {
    ami = var.ami-id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public["public-1"].id
    vpc_security_group_ids = [aws_security_group.bastion-sg.id]

    key_name = "Docker"

    tags = {
        Name = "Bastion-Host"
    }
}

# launch application server
resource "aws_instance" "app-server" {
    ami = var.ami-id
    instance_type = var.instance_type
    subnet_id = aws_subnet.private["private-1"].id
    vpc_security_group_ids = [ aws_security_group.app-sg.id]
    

    key_name = "Docker"
    tags = {
        Name = "App-Server"
    }
    user_data = <<-EOF
        #!/bin/bash
        apt update -y
        apt install -y nginx
        systemctl enable nginx
        systemctl start nginx
    EOF

}

#creat ALB
resource "aws_lb" "alb" {

  name               = "prod-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb-sg.id
  ]

  subnets = [
    aws_subnet.public["public-1"].id,
    aws_subnet.public["public-2"].id
  ]

  }

  resource "aws_lb_target_group" "app_tg" {

  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.Prod-vp.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb_target_group_attachment" "app" {

  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id = aws_instance.app-server.id

  port = 80
}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}












