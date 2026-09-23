variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  # t3.large = 2 vCPU / 8 GB. Bump to t3.xlarge (16 GB) if kind feels tight.
  default = "t3.xlarge"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in this region"
  type        = string
}

variable "public_key_path" {
  description = "Local path to the matching public key"
  default     = "~/.ssh/k8s-lab.pub"
}

variable "my_ip" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32"
  type        = string
}
