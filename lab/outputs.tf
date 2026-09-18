output "public_ip" {
  value = aws_instance.k8s_lab.public_ip
}

output "ssh" {
  value = "ssh ubuntu@${aws_instance.k8s_lab.public_ip}"
}
