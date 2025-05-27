terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "${var.project_name}"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# 1. VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# 2. IGW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# 3. Public subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # auto-assign public IP
  availability_zone       = data.aws_availability_zones.available.names[0]
}

# 4. Route table
resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

# 5. Route table association between route table and subnet.
resource "aws_route_table_association" "main_route_association" {
  route_table_id = aws_route_table.main_route.id
  subnet_id      = aws_subnet.main_subnet.id
}

# 6. create a security group for the EC2 instance.
resource "aws_security_group" "server_sg" {
  name        = "server-sg"
  description = "Allow SSH and HTTP inbound traffic."
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "server_sg_ingress_allow_ssh" {
  security_group_id = aws_security_group.server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "server_sg_ingress_allow_http" {
  security_group_id = aws_security_group.server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "server_sg_egress_allow_all" {
  security_group_id = aws_security_group.server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 7. IAM role to be attached to the instance.
data "aws_iam_policy_document" "ec2_cw_agent_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_cw_agent_role" {
  name               = "CloudWatchAgentServerRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_cw_agent_role_policy.json
}

# Attach CloudWatchAgentServerPolicy to the IAM role
# This policy grants permissions to write metrics, logs, and traces to CloudWatch.
resource "aws_iam_role_policy_attachment" "cw_agent_policy_attachment" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM managed instance core 
resource "aws_iam_role_policy_attachment" "ssm_core_policy_attachment" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# X-Ray core 
resource "aws_iam_role_policy_attachment" "xray_policy_attachment" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_instance_profile" "ec2_cw_agent_instance_profile" {
  name = "EC2CWAgentInstanceProfile"
  role = aws_iam_role.ec2_cw_agent_role.name
}

# . EC2 instance.
resource "aws_instance" "server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2_cw_agent_instance_profile.name
  subnet_id                   = aws_subnet.main_subnet.id
  vpc_security_group_ids      = [aws_security_group.server_sg.id]
  associate_public_ip_address = true
  monitoring                  = true
  key_name                    = var.key_name
  tags = {
    Name = "${var.project_name}-instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              yum install -y amazon-cloudwatch-agent
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World: $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
}



