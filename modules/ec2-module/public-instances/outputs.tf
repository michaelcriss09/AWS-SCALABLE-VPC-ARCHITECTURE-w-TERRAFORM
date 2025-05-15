output "public_instance_id" {
  value = aws_instance.public-instance.id
}

output "public_instance_ip" {
  value = aws_instance.public-instance.public_ip
}

output "public_security_group_id" {
  value = aws_security_group.public-sg.id
}