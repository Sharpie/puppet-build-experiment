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

variable "aws_subnet_id" {
  type = string
}

variable "ssh_pubkey" {
  type = string
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

data "aws_subnet" "raspbian_builder_subnet" {
  id = var.aws_subnet_id
}

resource "aws_key_pair" "puppet_agent_builder" {
  key_name_prefix = "puppet-agent-builder"
  public_key = var.ssh_pubkey
}

resource "aws_instance" "raspbian_builder" {
  ami           = data.aws_ami.debian_10.id
  instance_type = "m6g.large"
  key_name      = aws_key_pair.puppet_agent_builder.key_name
  subnet_id     = data.aws_subnet.raspbian_builder_subnet.id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size = 32
  }
}
