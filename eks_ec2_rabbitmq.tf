provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-cluster"
  cluster_version = "1.21"
  subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  vpc_id          = aws_vpc.main.id

  worker_groups = [
    {
      instance_type = "m5.large"
      asg_max_size  = 3
    },
  ]
}

resource "aws_instance" "rabbitmq" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet1.id
  security_groups             = [aws_security_group.eks_security_group.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "rabbitmq-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install epel -y
              sudo yum install rabbitmq-server -y
              sudo systemctl enable rabbitmq-server
              sudo systemctl start rabbitmq-server
            EOF
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
