terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_key_id" {
  type = string
}

variable "aws_key_secret" {
  type = string
}

variable "ssh_pubkey" {
  type = string
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}

data "aws_ami" "debian_10" {
  owners = ["aws-marketplace"]
  most_recent = true

  # Debian 10 Buster (ARM)
  #   https://wiki.debian.org/Cloud/AmazonEC2Image/Marketplace
  #
  # SSH username: admin
  filter {
    name = "product-code"
    values = ["1qy7erf9xr4bmkgjdpdyezu4w"]
  }
}

resource "aws_key_pair" "puppet_agent_builder" {
  key_name = "puppet-agent-builder"
  public_key = var.ssh_pubkey
}

### Networking

resource "aws_vpc" "raspbian_builder_vpc" {
  cidr_block           = "172.21.0.0/16"
}

resource "aws_internet_gateway" "raspbian_builder_gw" {
  vpc_id = aws_vpc.raspbian_builder_vpc.id
}

resource "aws_route_table" "raspbian_builder_routes" {
  vpc_id = aws_vpc.raspbian_builder_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.raspbian_builder_gw.id
  }
}

resource "aws_subnet" "raspbian_builder_subnet" {
  vpc_id     = aws_vpc.raspbian_builder_vpc.id
  cidr_block = "172.21.1.0/24"
}

resource "aws_route_table_association" "raspbian_builder_routing" {
  subnet_id      = aws_subnet.raspbian_builder_subnet.id
  route_table_id = aws_route_table.raspbian_builder_routes.id
}

resource "aws_default_security_group" "raspbian_builder_vpc_default_sg" {
  vpc_id     = aws_vpc.raspbian_builder_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "raspbian_builder" {
  ami           = data.aws_ami.debian_10.id
  instance_type = "m6g.large"
  key_name      = aws_key_pair.puppet_agent_builder.key_name
  subnet_id     = aws_subnet.raspbian_builder_subnet.id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size = 32
  }
}
