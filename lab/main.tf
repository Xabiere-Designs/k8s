terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  # Local state on purpose — this lab is disposable and separate from the
  # three-tier stack's remote backend. No shared state, no cross-contamination.
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "k8s-lab"
      ManagedBy = "terraform"
      Machine   = var.key_name
    }
  }
}

# Auto-detect public IP for the SSH rule; var.my_ip overrides if set
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_cidr = coalesce(var.my_ip, "${chomp(data.http.my_ip.response_body)}/32")
}

# Latest Ubuntu 24.04 LTS AMI, looked up at apply time
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC — keeps this lab from depending on your three-tier networking
data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "lab" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "k8s_lab" {
  name        = "${var.key_name}-sg"
  description = "SSH from my IP only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from me"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }

  egress {
    description = "All outbound (package installs, image pulls)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.key_name}-sg" }
}

resource "aws_instance" "k8s_lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.lab.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_lab.id]
  user_data                   = file("${path.module}/bootstrap.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_size = 30 # GB — kind images + your app image need headroom
    volume_type = "gp3"
    encrypted   = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = { Name = var.key_name }
}
