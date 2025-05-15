output "private_instance_id" {
  value = aws_instance.private-instance.id
}


output "private_security_group_id" {
  value = aws_security_group.private-sg.id
}