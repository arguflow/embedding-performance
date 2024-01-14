terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "cidr_subnet" {
  type = string
  default = "10.0.0.0/16"
}

variable ssh_pub_key_file {
  type = string
  default = "./ssh-key.pub"
}

variable "server-machine-type" {
  type = string
  default = "g3.4xlarge"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "sg_22_80" {
  name   = "sg_22"
  vpc_id = aws_vpc.vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7070
    to_port     = 7070
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "splade-embeddings" {
  ami           =  "ami-0bc3bf506b82cd41a"
  instance_type = var.server-machine-type
  user_data     = templatefile("./splade.yaml", {ssh_key: file(var.ssh_pub_key_file)}) # Cloudinit

  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 200 # In GB
    volume_type = "gp3"
  }

  tags = {
    Name = "splade-embeddings"
  }
}

resource "aws_instance" "side-car" {
  ami           =  "ami-0bc3bf506b82cd41a"
  instance_type = "t3.large"
  user_data     = templatefile("./sidecar.yaml", {ssh_key: file(var.ssh_pub_key_file)}) # Cloudinit

  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true

  tags = {
    Name = "arguflow-side-car"
  }
}

output "splade_ip" {
  value = aws_instance.splade-embeddings.public_ip
}

output "side_car_ip" {
  value = aws_instance.side-car.public_ip
}
