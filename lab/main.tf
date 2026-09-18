terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Local state on purpose — this lab is disposable and separate from the
  # three-tier stack's remote backend. No shared state, no cross-contamination.
}

provider "aws" {
  region = var.region
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
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "k8s_lab" {
  name        = "k8s-lab-sg"
  description = "SSH from my IP only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from me"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "k8s-lab" }
}

resource "aws_instance" "k8s_lab" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.k8s_lab.id]
  user_data              = file("${path.module}/bootstrap.sh")

  root_block_device {
    volume_size = 30 # GB — kind images + your app image need headroom
    volume_type = "gp3"
  }

  tags = { Name = "k8s-lab" }
}
