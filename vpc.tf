# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name        = "Nginx-VPC"
    Environment = var.environment_tag
  }
}

# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Nginx-Internet-gateway"
  }
}


# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet-1-cidr
  availability_zone       = var.region[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

# Create Public Subnet 2
# terraform aws create subnet
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet-2-cidr
  availability_zone       = var.region[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}


# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}


# Associate Public Subnet 2 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}


# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet-1-cidr
  availability_zone       = var.region[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 1 | App Tier"
  }
}


# Create Private Subnet 2
# terraform aws create subnet
resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet-2-cidr
  availability_zone       = var.region[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 2 | App Tier"
  }
}



# Allocate Elastic IP Address (EIP )
# terraform aws allocate elastic ip
resource "aws_eip" "eip-for-nat-gateway" {
  vpc = true

  tags = {
    Name = "Nginx-Elastic-IP "
  }

  depends_on = [aws_internet_gateway.internet-gateway]
}


# Create Nat Gateway in Public Subnet 1
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip-for-nat-gateway.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Nginx-VPC-Nat Gateway"
  }

  depends_on = [aws_internet_gateway.internet-gateway]

}



# Create Private Route Table and Add Route Through Nat Gateway 
# terraform aws create route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "Private Route Table "
  }
}


# Associate Private Subnet 1 with "Private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}



# Associate Private Subnet 2 with "Private Route Table 2"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}



# Create Security Group for the VPC
# terraform aws create security group
resource "aws_security_group" "Nginx_VCP_SG" {
  name        = "Nginx vpc security group"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Nginx VPC Security Group"
  }
}




# Create Security Group for the Application Load Balancer
# terraform aws create security group
resource "aws_security_group" "alb-security-group" {
  name        = "ALB Security Group"
  description = "Enable HTTP/HTTPS access on Port 80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Nginx-ALB Security Group"
  }
}


# Create Network interface for Bastion host
resource "aws_network_interface" "network-interface-BS" {
  subnet_id       = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]
}


# Create Network interface for webserver1
resource "aws_network_interface" "network-interface1" {
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]
}

# Create Network interface for webserver2
resource "aws_network_interface" "network-interface2" {
  subnet_id       = aws_subnet.private-subnet-2.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]
}


# Create Bastion host in the public subnet
# terraform aws create instance
resource "aws_instance" "jump-host" {
  ami           = var.ami_linux
  instance_type = "t2.micro"
  key_name        = "ansiblekeys"
  user_data       = file("linux-nginx.sh")
  subnet_id       = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]

  tags = {
    Name = "Nginx-Bastion-host"
  }

}




# Create Web Server instance 1
# terraform aws create instance
resource "aws_instance" "ec2-instance1" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name        = "ansiblekeys"
  user_data       = file("user_data.sh")
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]

  tags = {
    Name = "Nginx-server1"
  }

}



# Create Web Server instance 2
# terraform aws create instance
resource "aws_instance" "ec2-instance2" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name        = "ansiblekeys"
  user_data       = file("user_data1.sh")
  subnet_id       = aws_subnet.private-subnet-2.id
  security_groups = [aws_security_group.Nginx_VCP_SG.id]

  tags = {
    Name = "Nginx-server2"
  }

}



# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name                       = "Nginx-Application-LB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-security-group.id, aws_security_group.Nginx_VCP_SG.id]
  subnets                    = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  enable_deletion_protection = false

  tags = {
    Name = "Nginx Application-LB"
  }

}



# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name     = "Nginx-LB-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

}


# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create a listener on port 443 with forward action
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}



# Attach target groups to alb
resource "aws_lb_target_group_attachment" "ec2-instances1" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.ec2-instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2-instances2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.ec2-instance2.id
  port             = 80
}



# create a record set in route 53
resource "aws_route53_record" "record-subdomain" {
  zone_id = var.zone-id
  name    = "altschool.bukolatestimony.me"
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}


# create a record set in route 53
resource "aws_route53_record" "record-domain" {
  zone_id = var.zone-id
  name    = "www.altschool.bukolatestimony.me"
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}




# Create Launch launch template
resource "aws_launch_template" "Autoscaling-server" {
  name_prefix            = "Nginx-launch-template"
  image_id               = var.ami
  instance_type          = "t2.micro"
  key_name               = "ansiblekeys"
  user_data              = filebase64("auto-scale.sh")
  vpc_security_group_ids = [aws_security_group.Nginx_VCP_SG.id]

}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "Auto-sg" {
  name                = "Nginx-Autoscaling group"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  force_delete        = true
  target_group_arns   = [aws_lb_target_group.alb_target_group.arn]
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  launch_template {
    id      = aws_launch_template.Autoscaling-server.id
    version = "$Latest"
  }



  tag {
    key                 = "Name"
    value               = "Autoscaling-server"
    propagate_at_launch = true
  }
}



