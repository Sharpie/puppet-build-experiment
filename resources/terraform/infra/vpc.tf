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
  type      = string
  sensitive = true
}

variable "aws_key_secret" {
  type      = string
  sensitive = true
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret

  default_tags {
    tags = {
      Project = "puppet-agent-for-raspbian"
    }
  }
}

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
